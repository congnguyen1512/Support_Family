import { z } from 'zod';

export const inviteRelationshipSchema = z.object({
  target_uid: z.string().uuid(),
  relation_type: z.string().min(1, 'relation_type không được để trống'),
  reverse_relation_type: z
    .string()
    .min(1, 'reverse_relation_type không được để trống'),
});

export const updateRelationshipSchema = z.object({
  relation_type: z.string().min(1, 'relation_type không được để trống'),
  reverse_relation_type: z
    .string()
    .min(1, 'reverse_relation_type không được để trống')
    .optional(),
});