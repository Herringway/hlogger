/++
 + Adds support for logging prettier std.logger messages.
 + Authors: Cameron "Herringway" Ross
 + Copyright: Copyright Cameron Ross 2025
 + License: $(LINK2 http://www.boost.org/LICENSE_1_0.txt, Boost License 1.0).
 +/
module hlogger;

import std.datetime;
import std.format;
import std.logger;
import std.range;
import std.stdio;
/++
 + Logs messages to a .html file. When viewed in a browser, it provides an
 + easily-searchable and filterable view of logged messages.
 +/
public class HLogger : Logger {
	///File handle being written to.
	private File handle;
	static struct Config {
		bool fullTimestamp;
		bool includeTime = true;
		bool includeSource;
		bool includeThread;
		bool[LogLevel] showLogLevelLabel = [
			LogLevel.all: true,
			LogLevel.trace: true,
			LogLevel.info: true,
			LogLevel.warning: true,
			LogLevel.error: true,
			LogLevel.critical: true,
			LogLevel.fatal: true,
			LogLevel.off: true,
		];
		ubyte[LogLevel] levelColours = [
			LogLevel.all: 4,
			LogLevel.trace: 7,
			LogLevel.info: 10,
			LogLevel.warning: 11,
			LogLevel.error: 124,
			LogLevel.critical: 160,
			LogLevel.fatal: 9,
			LogLevel.off: 5,
		];
	}
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
		if (payLoad.logLevel >= logLevel) {
			auto writer = handle.lockingTextWriter;
			if (config.includeTime) {
				if (config.fullTimestamp) {
					payLoad.timestamp.toISOExtString(writer);
				} else {
					writer.formattedWrite!"%s"(cast(TimeOfDay)payLoad.timestamp);
				}
				put(writer, " ");
			}
			if (config.includeThread) {
				writer.formattedWrite!" %s"(payLoad.threadId);
			}
			if (config.includeSource) {
				writer.formattedWrite!" %s:%s:%s"(payLoad.file, payLoad.line, payLoad.funcName);
			}
			if (config.showLogLevelLabel.get(payLoad.logLevel, true)) {
				writer.formattedWrite!"[\x1B[38;5;%dm%s\x1B[0m] "(config.levelColours[payLoad.logLevel], payLoad.logLevel);
			}
			writer.formattedWrite!"%s\n"(payLoad.msg);
		}
	}
}
