import {PluginListenerHandle} from '@capacitor/core';

export interface jdudpPlugin {
  echo(options: { value: string }): Promise<{ value: string }>;
  searchCams(): Promise<unknown>;

  create(options?: { properties?: { name?: string, bufferSize?: number } }): Promise<{ socketId: number, ipv4: string, ipv6: string }>;

  update(options: { socketId: number, properties: { name?: string, bufferSize?: number } }): Promise<{}>;

  setPaused(options: { socketId: number, paused: boolean }): Promise<{}>;

  bind(options: { socketId: number, address: string, port: number }): Promise<{}>;

  send(options: { socketId: number, address: string, port: number, buffer: string }): Promise<{}>;

  closeAllSockets(): Promise<{}>;

  close(options: { socketId: number }): Promise<{}>;

  getInfo(options: { socketId: number }): Promise<{ socketId: number, bufferSize: number, name: string | null, paused: boolean, localAddress?: string, localPort?: number }>;

  getSockets(): Promise<{ sockets: { socketId: number, bufferSize: number, name: string | null, paused: boolean, localAddress?: string, localPort?: number }[] }>;

  joinGroup(options: { socketId: number, address: string }): Promise<{}>;

  leaveGroup(options: { socketId: number, address: string }): Promise<{}>;

  setMulticastTimeToLive(options: { socketId: number, ttl: number }): Promise<{}>;

  setBroadcast(options: { socketId: number, enabled: boolean }): Promise<{}>;

  setMulticastLoopbackMode(options: { socketId: number, enabled: boolean }): Promise<{}>;

  getJoinedGroups(): Promise<{ groups: string[] }>;

  addListener(events: "receive", functions: (params: { socketId: number, buffer: string }) => void): PluginListenerHandle;

  addListener(events: "receiveError", functions: (params: string) => void): PluginListenerHandle;

  startRtspStream(options: { ipadress: string, password: string, channel: string, stream: string }): Promise<{}>;

  stopRtspStream(): Promise<{}>;

}