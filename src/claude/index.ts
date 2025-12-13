/**
 * Snirklon - Claude Integration Module
 * 
 * Huvudsaklig export för alla Claude-relaterade funktioner
 */

// Types
export * from './types';

// Client
export { SnirklonClaudeClient, claudeClient } from './client';

// Personas
export { MUSICAL_PERSONAS, getPersonaByMood, getPersonasByComplexity, getAllPersonaIds } from './personas';

// Prompts
export { promptBuilders } from './prompts';

// Validators
export { validators, validateSequence, validateNote, parseSequenceFromResponse } from './validators';
