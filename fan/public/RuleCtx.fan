
** (Advanced) 
** Handed to 'Rule' classes during the matching process. 
@Js
mixin RuleCtx {
	
	** Call to process a sub-rule. Returns 'true' if it matched successfully.
	abstract Bool process(Rule rule)
	
	** Consumes 1 character from the underlying input stream.
	abstract Int readChar()

	** Peeks a character relative to the current position
	** (Does not consume any characters).
	** For example:
	** 
	**  - 'peekChar(2)'  - returns char at 'currentPos + 2'
	**  - 'peekChar(-1)' - returns char at 'currentPos - 1' 
	** 
	** Returns 'null' if out of bounds.
	abstract Int? peekChar(Int offset := 0)

	** Returns the current position in the underlying input stream.
	abstract Int currentPos()
	
	** Rolls back the underlying input stream to the given position. 
	abstract Void rollbackToPos(Int pos)

	** Returns 'true' if at the Start-Of-Stream. 
	abstract Bool sos()

	** Returns 'true' if at the End-Of-Stream. 
	abstract Bool eos()

	** Logs the given message to debug. It is formatted to be the same as the other Pegger debug messages. 
	abstract Void log(Str msg)

	** Returns a PEG specific 'ParseErr' to be thrown.
	abstract PegParseErr parseErr(Str errMsg)

	** Returns the string we are matching against. 
	abstract Str str()
}
