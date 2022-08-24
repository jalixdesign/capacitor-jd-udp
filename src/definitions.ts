export interface jdudpPlugin {
  echo(options: { value: string }): Promise<{ value: string }>;
  searchCams(): Promise<Object>;
}
