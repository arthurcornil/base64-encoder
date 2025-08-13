const std = @import("std");
const print = std.debug.print;

const Base64 = struct {
    table: *const [64]u8,

    pub fn init() Base64 {
        const upper = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
        const lower = "abcdefghijklmnopqrstuvwxyz";
        const numbers_symb = "0123456789+/";
        return Base64{
            .table = upper ++ lower ++ numbers_symb
        };
    }

    fn get_nth_digit(self: Base64, n: usize) u8 {
        return self.table[n];
    }
    
    pub fn encode(self: Base64, input: []const u8, allocator: std.mem.Allocator) ![]u8 {
        const output_len = try get_output_len(input);
        const output: []u8 = try allocator.alloc(u8, output_len);
        var byte_counter: u64 = 0;
        var buffer = [3]u8{ 0, 0, 0 };
        var output_index: u64 = 0;
        var n: u8 = 0;
        
        for (input) |byte| {
            buffer[byte_counter] = byte;
            byte_counter += 1;
            if (byte_counter == 1) {
                n = buffer[0] >> 2;
                output[output_index] = self.get_nth_digit(n);
                output_index += 1;
            }
            if (byte_counter < 3)
                continue ;
            byte_counter = 0;
            n = ((buffer[0] & 3) << 4) | (buffer[1] >> 4);
            output[output_index] = self.get_nth_digit(n);
            output_index += 1;
            n = ((buffer[1] & 15) << 2) | (buffer[2] >> 6);
            output[output_index] = self.get_nth_digit(n);
            output_index += 1;
            n = buffer[2] & 63;
            output[output_index] = self.get_nth_digit(n);
            output_index += 1;
        }
        if (byte_counter == 2) {
            n = ((buffer[0] & 3) << 4) | (buffer[1] >> 4);
            output[output_index] = self.get_nth_digit(n);
            n = (buffer[1] & 15) << 2;
            output_index += 1;
            output[output_index] = self.get_nth_digit(n);
            output_index += 1;
            output[output_index] = '=';
        }
        else if (byte_counter == 1) {
            n = (buffer[0] & 3) << 4;
            output[output_index] = self.get_nth_digit(n);
            output_index += 1;
            output[output_index] = '=';
            output_index += 1;
            output[output_index] = '=';
        }
        return output;
    }
};

fn get_output_len(str: []const u8) !usize {
    if (str.len <= 3)
        return @as(usize, 4);
    var num_bytes: usize = try std.math.divCeil(usize, str.len, 3);
    num_bytes *= 4;
    return num_bytes;
}

pub fn main() !void {
    const base64 = Base64.init();
    const input = "hello, world!";
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    const output: []u8 = try base64.encode(input, allocator);
    defer allocator.free(output);

    print("{s}\n", .{output});
}
