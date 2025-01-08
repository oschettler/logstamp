const std = @import("std");
const time = std.time;

pub fn main() !void {
    const allocator = std.heap.page_allocator;
    var stdin = std.io.getStdIn().reader();
    var stdout = std.io.getStdOut().writer();

    var buf: [1024]u8 = undefined;
    var line_reader = std.io.BufferedInputStream.init(&stdin, &buf);

    var clock = try time.Clock.create(allocator);

    while (true) {
        const line = try line_reader.readUntilDelimiterOrEof('\n');
        if (line == null) break; // EOF

        var timestamp_buf: [30]u8 = undefined;
        const now = try clock.getTimestamp();
        const ts = try time.formatISO8601(&timestamp_buf, now);

        try stdout.print("{s} {s}\n", .{ts, line.?});
    }
}

pub fn tests() !void {
    // Test: Check ISO timestamp formatting
    {
        var timestamp_buf: [30]u8 = undefined;
        const ts = try time.formatISO8601(&timestamp_buf, time.Timestamp{ .seconds = 0, .nanoseconds = 0 });
        try std.testing.expect(ts.startsWith("1970-01-01T00:00:00"));
    }

    // Test: Verify that the line is correctly stamped
    {
        const input = "Test log line\n";
        var input_stream = std.io.BufferInStream.init(input); // Mock input

        var output_buf: [1024]u8 = undefined;
        var output_stream = std.io.BufferOutStream.init(&output_buf);

        var buf: [1024]u8 = undefined;
        var line_reader = std.io.BufferedInputStream.init(&input_stream, &buf);

        const line = try line_reader.readUntilDelimiterOrEof('\n');
        if (line != null) {
            var timestamp_buf: [30]u8 = undefined;
            const now = time.Timestamp{ .seconds = 0, .nanoseconds = 0 };
            const ts = try time.formatISO8601(&timestamp_buf, now);
            try output_stream.print("{s} {s}\n", .{ts, line.?});
        }

        const result = output_stream.buffer[0..output_stream.offset];
        const expected = "1970-01-01T00:00:00 Test log line\n";
        try std.testing.expectEqualStrings(result, expected);
    }
}
