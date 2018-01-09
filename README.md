# loadavg.sh
Simple shell script to SIGstop/start given program based on overall system load

*Parameters are:*

-e / -exe   :  name of program {$0} to stop/start based upon load

-l / -limit :  Max load limit (supported to hundreths - e.g. 3.13)

-q / -quiet :  Be quiet (don't report what you're doing).

*To Do:*

<del>* Implement "only send notices when not quiet if state has changed", so it doesn't tell you what it does every refresh.</del> Done.

* Make more compatible by reducing the BASHisms.
