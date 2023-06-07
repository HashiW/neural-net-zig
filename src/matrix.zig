const std = @import("std");

const mem = std.mem;
const AllocationError = error{OutOfMemory};

const ArrayList = std.ArrayList;
const RndGen = std.rand.DefaultPrng;
var arena = std.heap.ArenaAllocator;

const MatrixError = error{ InvalidDimensions, AllocationError };

// TODO: Add A print function for a clean nice print of the matrices

// TODO: Add tests for everything to make sure they working properly

pub const Matrix = struct {
    rows: u16,
    cols: u16,
    data: []f32,

    const Self = @This();

    // TODO: Fix this
    pub fn init(comptime rows: usize, comptime cols: usize, comptime data: []const f32, allocator: *std.mem.Allocator) !Self {
        _ = allocator;
        // const data = try allocator.alloc(f32, rows * cols);

        return Self{ .rows = rows, .cols = cols, .data = data[0..] };
    }

    pub fn random(comptime rows: u16, comptime cols: u16, comptime seed: u8, allocator: *std.mem.Allocator) !Self {
        var prng = std.rand.DefaultPrng.init(seed);
        const rand = prng.random();
        var data = try allocator.alloc(f32, rows * cols);

        for (0..rows * cols) |i| {
            const num = rand.float(f32);
            data[i] = num;
        }

        return Matrix{ .rows = rows, .cols = cols, .data = data };
    }

    pub fn add(self: Matrix, other: Matrix) !Matrix {
        if (self.rows != other.rows or self.cols != other.cols) {
            return MatrixError.InvalidDimensions;
        }

        for (0..(self.data.len - 1)) |i| {
            self.data[i] = self.data[i] + other.data[i];
        }
        return self;
    }

    pub fn subtract(self: Matrix, other: Matrix) !Matrix {
        if (self.rows != other.rows or self.cols != other.cols) {
            return MatrixError.InvalidDimensions;
        }

        for (0..(self.data.len - 1)) |i| {
            self.data[i] = self.data[i] - other.data[i];
        }
        return self;
    }

    pub fn elementwise_multiply(self: Matrix, other: Matrix, allocator: *std.mem.Allocator) !Matrix {

        // size(self) == self(other) -> just use data slice to multiply

        if (self.rows != other.rows or self.cols != other.cols) {

            // zig so weird it usees or instead of || hahahah

            return MatrixError.InvalidDimensions;
        }

        var data = try allocator.alloc(f32, self.rows * self.cols);

        for (0..self.data.len - 1) |i| {
            data[i] = self.data[i] * other.data[i];
        }

        return Matrix{ .rows = self.rows, .cols = self.cols, .data = data[0..] };
    }

    pub fn dot_multiply(self: Matrix, other: Matrix, allocator: *std.mem.Allocator) !Matrix {
        if (self.cols != other.rows) {
            return MatrixError.InvalidDimensions;
        }

        var result_data = try allocator.alloc(f32, self.rows * other.cols);

        for (0..self.rows) |i| {
            for (0..other.cols) |j| {
                var sum: f32 = 0.0;

                for (0..self.cols) |k| {
                    sum += self.data[i * self.cols + k] * other.data[k * other.cols + j];
                }
                result_data[i * other.cols + j] = sum;
            }
        }

        return Matrix{ .rows = self.rows, .cols = other.cols, .data = result_data[0..] };
    }

    pub fn transpose(self: Matrix, allocator: *std.mem.Allocator) !Matrix {
        var transpose_result = try allocator.alloc(f32, self.rows * self.cols);

        std.debug.print("{any}\n", .{transpose_result});

        for (0..self.rows) |i| {
            for (0..self.cols) |j| {
                transpose_result[j * self.rows + i] = self.data[i * self.cols + j];
            }
        }

        return Matrix{ .rows = self.cols, .cols = self.rows, .data = transpose_result[0..] };
    }
};
