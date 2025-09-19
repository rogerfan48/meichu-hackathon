/* Lightweight structured logging helper */
export function logInfo(scope: string, message: string, extra?: Record<string, unknown>) {
  console.log(JSON.stringify({ level: 'info', scope, message, ...extra, ts: new Date().toISOString() }));
}

export function logError(scope: string, error: unknown, extra?: Record<string, unknown>) {
  console.error(JSON.stringify({
    level: 'error',
    scope,
    error: error instanceof Error ? error.message : String(error),
    stack: error instanceof Error ? error.stack : undefined,
    ...extra,
    ts: new Date().toISOString()
  }));
}
