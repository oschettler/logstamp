const std = @import("std");
const time = std.time;

pub fn main() !void {
    var stdin = std.io.getStdIn().reader();
    var stdout = std.io.getStdOut().writer();

    var buf: [1024]u8 = undefined;
    var line_reader = std.io.BufferedInputStream.init(&stdin, &buf);

    while (true) {
        var line = try line_reader.readUntilDelimiterOrEof('\n');
        if (line == null) break; // EOF

        var timestamp_buf: [30]u8 = undefined;
        const now = time.Timestamp{ .seconds = @intCast(u64, std.time.milliTimestamp() / 1000), .nanoseconds = 0 };
        const ts = try time.formatISO8601(&timestamp_buf, now);

        try stdout.print("{s} {s}\n", .{ts, line.?});
    }
}

pub fn tests() !void {
    const std = @import("std");

    // Test: Check ISO timestamp formatting
    {
        var timestamp_buf: [30]u8 = undefined;
        const ts = try time.formatISO8601(&timestamp_buf, time.Timestamp{ .seconds = 0, .nanoseconds = 0 });
        try std.testing.expect(ts.startsWith("1970-01-01T00:00:00"));
    }

    // Test: Verify that the line is correctly stamped
    {
        const input = "Test log line\n";
        var input_stream = std.io.fixedBufferStream(&input); // Mock input

        var output_buf: [1024]u8 = undefined;
        var output_stream = std.io.fixedBufferStream(&output_buf);

        var buf: [1024]u8 = undefined;
        var line_reader = std.io.BufferedInputStream.init(&input_stream, &buf);

        var line = try line_reader.readUntilDelimiterOrEof('\n');
        if (line != null) {
            var timestamp_buf: [30]u8 = undefined;
            const now = time.Timestamp{ .seconds = 0, .nanoseconds = 0 };
            const ts = try time.formatISO8601(&timestamp_buf, now);
            try output_stream.writer().print("{s} {s}\n", .{ts, line.?});
        }

        const result = output_buf[0..std.mem.indexOf(u8, &output_buf, 0)];
        const expected = "1970-01-01T00:00:00 Test log line\n";
        try std.testing.expectEqualStrings(result, expected);
    }
}
