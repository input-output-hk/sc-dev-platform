import { Router } from "express";
import { PluginEnvironment } from "../types";



export default async function createPlugin(
    env: PluginEnvironment,
  ): Promise<Router> {
    env.eventBroker.publish({
      topic: 'publish.example',
      eventPayload: { message: 'Hello, World!' },
      metadata: {},
    });

    return Router();
  }

