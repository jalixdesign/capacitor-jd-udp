import { WebPlugin } from '@capacitor/core';

import type { jdudpPlugin } from './definitions';

export class jdudpWeb extends WebPlugin implements jdudpPlugin {

  async echo(options: { value: string }): Promise<{ value: string }> {
    console.log('ECHO', options);
    return options;
  }

  async searchCams(): Promise<unknown> {
    console.log('jdudp -> web -> searchCams -> Start');

    const test = {
      data: { test: 'test' },
    };
    return test;
  }

  async create(options?: { properties?: { name?: string, bufferSize?: number } }): Promise<{ socketId: number, ipv4: string, ipv6: string }>{
    console.log('Nicht in Webversion', options);
    const ret = {
      socketId: 1000, 
      ipv4: 'test', 
      ipv6: 'test'
    }
    return ret;
  }

  async update(options: { socketId: number, properties: { name?: string, bufferSize?: number } }): Promise<{}>{
    console.log('Nicht in Webversion', options);
    const ret = {
      socketId: 1000, 
      ipv4: 'test', 
      ipv6: 'test'
    }
    return ret;
  }

  async setPaused(options: { socketId: number, paused: boolean }): Promise<{}>{
    console.log('Nicht in Webversion', options);
    const ret = {
      socketId: 1000, 
      ipv4: 'test', 
      ipv6: 'test'
    }
    return ret;
  }

  async bind(options: { socketId: number, address: string, port: number }): Promise<{}>{
    console.log('Nicht in Webversion', options);
    const ret = {
      socketId: 1000, 
      ipv4: 'test', 
      ipv6: 'test'
    }
    return ret;
  }

  async send(options: { socketId: number, address: string, port: number, buffer: string }): Promise<{}>{
    console.log('Nicht in Webversion', options);
    const ret = {
      socketId: 1000, 
      ipv4: 'test', 
      ipv6: 'test'
    }
    return ret;
  }

  async closeAllSockets(): Promise<{}>{
    console.log('Nicht in Webversion');
    const ret = {
      socketId: 1000, 
      ipv4: 'test', 
      ipv6: 'test'
    }
    return ret;
  }

  async close(options: { socketId: number }): Promise<{}>{
    console.log('Nicht in Webversion', options);
    const ret = {
      socketId: 1000, 
      ipv4: 'test', 
      ipv6: 'test'
    }
    return ret;
  }

  async getInfo(options: { socketId: number }): Promise<{ socketId: number, bufferSize: number, name: string | null, paused: boolean, localAddress?: string, localPort?: number }>{
    console.log('Nicht in Webversion', options);
    const ret = {
      socketId: 10, 
      bufferSize: 10, 
      name: 'test', 
      paused: true,
      localPort: 10
    }
    return ret;
  }

  async getSockets(): Promise<{ sockets: { socketId: number, bufferSize: number, name: string | null, paused: boolean, localAddress?: string, localPort?: number }[] }>{
    console.log('Nicht in Webversion');
    let socket = { socketId: 10, bufferSize: 10, name: 'test', paused: true, localAddress: 'test', localPort: 10 };
    let ret = { sockets: [socket, socket] };
    return ret;
  }

  async joinGroup(options: { socketId: number, address: string }): Promise<{}>{
    console.log('Nicht in Webversion', options);
    const ret = {
      socketId: 1000, 
      ipv4: 'test', 
      ipv6: 'test'
    }
    return ret;
  }

  async leaveGroup(options: { socketId: number, address: string }): Promise<{}>{
    console.log('Nicht in Webversion', options);
    const ret = {
      socketId: 1000, 
      ipv4: 'test', 
      ipv6: 'test'
    }
    return ret;
  }

  async setMulticastTimeToLive(options: { socketId: number, ttl: number }): Promise<{}>{
    console.log('Nicht in Webversion', options);
    const ret = {
      socketId: 1000, 
      ipv4: 'test', 
      ipv6: 'test'
    }
    return ret;
  }

  async setBroadcast(options: { socketId: number, enabled: boolean }): Promise<{}>{
    console.log('Nicht in Webversion', options);
    const ret = {
      socketId: 1000, 
      ipv4: 'test', 
      ipv6: 'test'
    }
    return ret;
  }

  async setMulticastLoopbackMode(options: { socketId: number, enabled: boolean }): Promise<{}>{
    console.log('Nicht in Webversion', options);
    const ret = {
      socketId: 1000, 
      ipv4: 'test', 
      ipv6: 'test'
    }
    return ret;
  }

  async getJoinedGroups(): Promise<{ groups: string[] }>{
    console.log('Nicht in Webversion');
    const ret = { groups: ['test'] }
    return ret;
  }



}
