import { registerPlugin } from '@capacitor/core';

import type { jdudpPlugin } from './definitions';

const jdudp = registerPlugin<jdudpPlugin>('jdudp', {
  web: () => import('./web').then((m) => new m.jdudpWeb()),
});

export * from './definitions';
export { jdudp };
