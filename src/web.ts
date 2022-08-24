import { WebPlugin } from '@capacitor/core';

import type { jdudpPlugin } from './definitions';

export class jdudpWeb extends WebPlugin implements jdudpPlugin {
  async echo(options: { value: string }): Promise<{ value: string }> {
    console.log('ECHO', options);
    return options;
  }

  async searchCams(): Promise<Object> {
    console.log('jdudp -> web -> searchCams -> Start');
    
    var test = {
      data: {'test': 'test'}
    }
    return test;
  }
}
