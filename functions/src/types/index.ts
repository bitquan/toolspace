export interface User {
  id: string;
  email: string;
  displayName?: string;
  createdAt: Date;
  updatedAt: Date;
}

export interface ToolConfig {
  id: string;
  name: string;
  description: string;
  enabled: boolean;
  settings?: Record<string, any>;
}

export interface BillingPlan {
  id: string;
  name: string;
  price: number;
  features: string[];
  maxUsage?: Record<string, number>;
}
