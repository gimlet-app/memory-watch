# memwatch
Ruby-based process memory watcher, requires GNU `ps` and `grep`

Basically, a very little process that polls `ps` to see the RSS for a set of processes matching a regular expression, and if it's over a threshold, send a signal to it. Useful for keeping unicorn or puma workers' memory usage in check.

You could use `ulimit` to do something similar, but this lets you send a signal to offending processes so they'll gracefully finish handling their request, rather than causing memory allocation to fail and interrupting request processing.
