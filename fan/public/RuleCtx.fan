
** (Advanced) 
** Handed to 'Rule' classes during the matching process. 
@Js
mixin RuleCtx {
	
	** Call to process a sub-rule. Returns 'true' if it matched successfully.
	abstract Bool process(Rule rule)
	
	** Consumes 1 character from the underlying input stream.
	** 
	** Retuns '0' if out of bounds.
	abstract Int readChar()

	** Consumes and returns as a string, the next XX characters.
	** 'readChar()' is much more performant (creates less objects), but use 'readStr()' for a 
	** quick win!
	** 
	** Returns 'null' if out of bounds.
	abstract Str? readStr(Int size)

	** Peeks a character relative to the current position
	** (Does not consume any characters).
	** For example:
	** 
	**  - 'peekChar(2)'  - returns char at 'currentPos + 2'
	**  - 'peekChar(-1)' - returns char at 'currentPos - 1' 
	** 
	** Returns 'null' if out of bounds.
	abstract Int? peekChar(Int offset := 0)
	
	** Peeks and returns as a string, the next XX characters.
	** 'peekChar()' is much more performant (creates less objects), but use 'peekStr()' for a 
	** quick win!
	** 
	** Returns 'null' if out of bounds.
	abstract Str? peekStr(Int size)

	** Returns the current position in the underlying input stream.
	abstract Int currentPos()
	
	** Rolls back the underlying input stream to the given position. 
	abstract Void rollbackToPos(Int pos)

	** Returns 'true' if at the Start-Of-Stream. 
	abstract Bool sos()

	** Returns 'true' if at the End-Of-Stream. 
	abstract Bool eos()

	** Logs the given message to debug. It is formatted to be the same as the other Pegger 
	** debug messages. 
	abstract Void log(Str msg)

	** Returns a PEG specific 'ParseErr' to be thrown.
	abstract PegParseErr parseErr(Str errMsg)

	** Sets user-defined meta to be returned in the resultant 'Match'.
	** This should be called by Rule subclasses during their 'doProcess()' method, should they 
	** expect to return 'true'.
	abstract Void setMeta(Obj? meta)
	
	** Returns any previously set, user-defined meta from the last Rule processed.
	abstract Obj? getMeta()
	
	** Returns the string we are matching against. 
	abstract Str str()
}
