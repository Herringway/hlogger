/++
 + Adds support for logging prettier std.experimental.logger messages.
 + Authors: Cameron "Herringway" Ross
 + Copyright: Copyright Cameron Ross 2022
 + License: $(LINK2 http://www.boost.org/LICENSE_1_0.txt, Boost License 1.0).
 +/
module prettylogger;
import std.experimental.logger;
import std.stdio;
/++
 + Logs messages to a .html file. When viewed in a browser, it provides an
 + easily-searchable and filterable view of logged messages.
 +/
public class PrettyLogger : Logger {
	///File handle being written to.
	private File handle;
	Config config;

	/++
	 + Writes a log file using an already-opened handle. Note that having
	 + pre-existing data in the file will likely cause display errors.
	 + Params:
	 +   file = Prepared file handle to write log to
	 +   lv = Minimum message level to write to the log
	 +/
	this(File file, LogLevel lv = LogLevel.all) @safe
	in(file.isOpen)
	{
		super(lv);
		handle = file;
	}

	/// ditto
	this(LogLevel lv = LogLevel.all) @system {
		this(stdout, lv);
	}
	/++
	 + Writes a log message. For internal use by std.experimental.logger.
	 + Params:
	 +   payLoad = Data for the log entry being written
	 + See_Also: $(LINK https://dlang.org/library/std/experimental/logger.html)
	 +/
	override public void writeLogMsg(ref LogEntry payLoad) @safe {
		import std.format : formattedWrite;
		import std.datetime : TimeOfDay;
		import std.range : put;
		auto logLevelColours = [
			LogLevel.all: 4,
			LogLevel.trace: 7,
			LogLevel.info: 10,
			LogLevel.warning: 11,
			LogLevel.error: 124,
			LogLevel.critical: 160,
			LogLevel.fatal: 9,
			LogLevel.off: 5,
		];
		if (payLoad.logLevel >= logLevel) {
			handle.lockingTextWriter.formattedWrite!"[\x1B[38;5;%dm%s - %s\x1B[0m] %s\n"(logLevelColours[payLoad.logLevel], cast(TimeOfDay)payLoad.timestamp, payLoad.logLevel, payLoad.msg);
		}
	}
}

struct Config {
	ubyte[LogLevel] levelColours;
}
