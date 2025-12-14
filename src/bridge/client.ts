/**
 * WebSocket client for TypeScript ↔ Swift bridge
 * Connects to the VintageVoltage sequencer
 */

import WebSocket from 'ws';
import { EventEmitter } from 'events';

// Types
export interface BridgeMessage {
  id: string;
  type: MessageType;
  payload: MessagePayload;
  timestamp: string;
}

export type MessageType =
  | 'generate_sequence'
  | 'generate_drum_pattern'
  | 'generate_arpeggio'
  | 'style_transform'
  | 'mood_morph'
  | 'jam_session'
  | 'sequence_generated'
  | 'pattern_generated'
  | 'error'
  | 'state_update'
  | 'transport_update'
  | 'pattern_update'
  | 'play'
  | 'stop'
  | 'set_tempo'
  | 'load_pattern'
  | 'update_step'
  | 'update_track';

export type MessagePayload =
  | GenerateRequest
  | SequenceResult
  | DrumPatternResult
  | StateSync
  | TransportCommand
  | StepUpdate
  | TrackUpdate
  | ErrorPayload
  | null;

export interface GenerateRequest {
  type: 'generate_request';
  data: {
    prompt: string;
    persona?: string;
    context: SequencerContext;
    options?: GenerationOptions;
  };
}

export interface SequencerContext {
  bpm: number;
  timeSignature: [number, number];
  key?: string;
  scale?: string;
  currentPatternLength: number;
  existingTracks?: TrackSummary[];
}

export interface TrackSummary {
  name: string;
  type: string;
  midiChannel: number;
  enabledSteps: number[];
}

export interface GenerationOptions {
  style?: string;
  density?: number;
  variation?: number;
  humanize?: number;
}

export interface SequenceResult {
  type: 'sequence_result';
  data: {
    trackName: string;
    notes: GeneratedNote[];
    metadata: GenerationMetadata;
  };
}

export interface GeneratedNote {
  pitch: number;
  velocity: number;
  start: number;
  duration: number;
  slide?: boolean;
  accent?: boolean;
}

export interface DrumPatternResult {
  type: 'drum_pattern_result';
  data: {
    tracks: GeneratedDrumTrack[];
    metadata: GenerationMetadata;
  };
}

export interface GeneratedDrumTrack {
  instrument: string;
  steps: GeneratedDrumStep[];
}

export interface GeneratedDrumStep {
  position: number;
  velocity: number;
  probability?: number;
  flam?: boolean;
}

export interface GenerationMetadata {
  generatedBy: string;
  prompt: string;
  confidence?: number;
  timestamp: string;
}

export interface StateSync {
  type: 'state_sync';
  data: {
    isPlaying: boolean;
    tempo: number;
    currentStep: number;
    currentPattern: number;
    patterns: PatternSummary[];
  };
}

export interface PatternSummary {
  id: string;
  name: string;
  length: number;
  trackCount: number;
}

export interface TransportCommand {
  type: 'transport_command';
  data: {
    action: 'play' | 'stop' | 'pause' | 'setTempo';
    value?: number;
  };
}

export interface StepUpdate {
  type: 'step_update';
  data: {
    trackIndex: number;
    stepIndex: number;
    enabled?: boolean;
    velocity?: number;
    probability?: number;
    condition?: string;
  };
}

export interface TrackUpdate {
  type: 'track_update';
  data: {
    trackIndex: number;
    name?: string;
    muted?: boolean;
    solo?: boolean;
    midiChannel?: number;
  };
}

export interface ErrorPayload {
  type: 'error';
  data: {
    code: string;
    message: string;
  };
}

// Bridge Client
export class BridgeClient extends EventEmitter {
  private ws: WebSocket | null = null;
  private url: string;
  private reconnectInterval: number = 3000;
  private reconnectAttempts: number = 0;
  private maxReconnectAttempts: number = 10;
  private isConnecting: boolean = false;
  private pendingRequests: Map<string, {
    resolve: (value: any) => void;
    reject: (reason: any) => void;
    timeout: NodeJS.Timeout;
  }> = new Map();

  constructor(url: string = 'ws://localhost:8765') {
    super();
    this.url = url;
  }

  // Connection
  async connect(): Promise<void> {
    if (this.isConnecting || this.ws?.readyState === WebSocket.OPEN) {
      return;
    }

    this.isConnecting = true;

    return new Promise((resolve, reject) => {
      try {
        this.ws = new WebSocket(this.url);

        this.ws.on('open', () => {
          console.log('🌐 Connected to VintageVoltage sequencer');
          this.isConnecting = false;
          this.reconnectAttempts = 0;
          this.emit('connected');
          resolve();
        });

        this.ws.on('message', (data: WebSocket.Data) => {
          this.handleMessage(data);
        });

        this.ws.on('close', () => {
          console.log('🔌 Disconnected from sequencer');
          this.isConnecting = false;
          this.emit('disconnected');
          this.attemptReconnect();
        });

        this.ws.on('error', (error) => {
          console.error('❌ WebSocket error:', error.message);
          this.isConnecting = false;
          this.emit('error', error);
          reject(error);
        });

      } catch (error) {
        this.isConnecting = false;
        reject(error);
      }
    });
  }

  disconnect(): void {
    if (this.ws) {
      this.ws.close();
      this.ws = null;
    }
    this.pendingRequests.forEach(({ reject, timeout }) => {
      clearTimeout(timeout);
      reject(new Error('Disconnected'));
    });
    this.pendingRequests.clear();
  }

  private attemptReconnect(): void {
    if (this.reconnectAttempts >= this.maxReconnectAttempts) {
      console.log('❌ Max reconnect attempts reached');
      return;
    }

    this.reconnectAttempts++;
    console.log(`🔄 Reconnecting in ${this.reconnectInterval}ms (attempt ${this.reconnectAttempts})`);

    setTimeout(() => {
      this.connect().catch(() => {});
    }, this.reconnectInterval);
  }

  // Message Handling
  private handleMessage(data: WebSocket.Data): void {
    try {
      const message: BridgeMessage = JSON.parse(data.toString());
      
      // Check if this is a response to a pending request
      if (this.pendingRequests.has(message.id)) {
        const { resolve, timeout } = this.pendingRequests.get(message.id)!;
        clearTimeout(timeout);
        this.pendingRequests.delete(message.id);
        resolve(message);
        return;
      }

      // Emit events based on message type
      switch (message.type) {
        case 'state_update':
          this.emit('stateUpdate', message.payload);
          break;
        case 'transport_update':
          this.emit('transportUpdate', message.payload);
          break;
        case 'pattern_update':
          this.emit('patternUpdate', message.payload);
          break;
        case 'sequence_generated':
          this.emit('sequenceGenerated', message.payload);
          break;
        case 'pattern_generated':
          this.emit('patternGenerated', message.payload);
          break;
        case 'error':
          this.emit('error', message.payload);
          break;
        default:
          this.emit('message', message);
      }
    } catch (error) {
      console.error('❌ Failed to parse message:', error);
    }
  }

  // Sending Messages
  private send(message: BridgeMessage): void {
    if (this.ws?.readyState !== WebSocket.OPEN) {
      throw new Error('Not connected to sequencer');
    }
    this.ws.send(JSON.stringify(message));
  }

  private async sendAndWait<T>(message: BridgeMessage, timeoutMs: number = 30000): Promise<T> {
    return new Promise((resolve, reject) => {
      const timeout = setTimeout(() => {
        this.pendingRequests.delete(message.id);
        reject(new Error('Request timeout'));
      }, timeoutMs);

      this.pendingRequests.set(message.id, { resolve, reject, timeout });
      this.send(message);
    });
  }

  // Transport Controls
  async play(): Promise<void> {
    const message = this.createMessage('play', {
      type: 'transport_command',
      data: { action: 'play' }
    });
    this.send(message);
  }

  async stop(): Promise<void> {
    const message = this.createMessage('stop', {
      type: 'transport_command',
      data: { action: 'stop' }
    });
    this.send(message);
  }

  async setTempo(bpm: number): Promise<void> {
    const message = this.createMessage('set_tempo', {
      type: 'transport_command',
      data: { action: 'setTempo', value: bpm }
    });
    this.send(message);
  }

  // Generation Requests
  async generateSequence(request: {
    prompt: string;
    persona?: string;
    context: SequencerContext;
    options?: GenerationOptions;
  }): Promise<SequenceResult> {
    const message = this.createMessage('generate_sequence', {
      type: 'generate_request',
      data: request
    });
    return this.sendAndWait<SequenceResult>(message);
  }

  async generateDrumPattern(request: {
    prompt: string;
    persona?: string;
    context: SequencerContext;
    options?: GenerationOptions;
  }): Promise<DrumPatternResult> {
    const message = this.createMessage('generate_drum_pattern', {
      type: 'generate_request',
      data: request
    });
    return this.sendAndWait<DrumPatternResult>(message);
  }

  async jamSession(request: {
    prompt: string;
    context: SequencerContext;
  }): Promise<SequenceResult | DrumPatternResult> {
    const message = this.createMessage('jam_session', {
      type: 'generate_request',
      data: request
    });
    return this.sendAndWait(message);
  }

  // Step/Track Updates
  async updateStep(update: StepUpdate['data']): Promise<void> {
    const message = this.createMessage('update_step', {
      type: 'step_update',
      data: update
    });
    this.send(message);
  }

  async updateTrack(update: TrackUpdate['data']): Promise<void> {
    const message = this.createMessage('update_track', {
      type: 'track_update',
      data: update
    });
    this.send(message);
  }

  // Utility
  private createMessage(type: MessageType, payload: MessagePayload): BridgeMessage {
    return {
      id: this.generateId(),
      type,
      payload,
      timestamp: new Date().toISOString()
    };
  }

  private generateId(): string {
    return `msg_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;
  }

  get isConnected(): boolean {
    return this.ws?.readyState === WebSocket.OPEN;
  }
}

// Default export
export default BridgeClient;

