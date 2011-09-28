class CPU
    attr_writer :reg_a, :reg_x, :reg_i1, :reg_i2, :reg_i3, :reg_i4, :reg_i5, :reg_i6, :reg_j, :overflow_toggle, :comparison, :mem, :instructions, :program
    attr_reader :reg_a, :reg_x, :reg_i1, :reg_i2, :reg_i3, :reg_i4, :reg_i5, :reg_i6, :reg_j, :overflow_toggle, :comparison, :mem, :instructions, :program
    def initialize
        @reg_a  = Array.new(6)
        @reg_x  = Array.new(6)
        @reg_i1 = Array.new(3)
        @reg_i2 = Array.new(3)
        @reg_i3 = Array.new(3)
        @reg_i4 = Array.new(3)
        @reg_i5 = Array.new(3)
        @reg_i6 = Array.new(3)
        @reg_j  = Array.new(3)
        @overflow_toggle = false
        @comparison = { :equal => false, :less => false, :greater => false }
        @mem = nil
        @instructions = {}
        @program

        self.set_instructions
        self.reset
    end

    def reset
        new_mem = Array.new(4000)
        @mem = new_mem.collect { |x| Array.new(6) }
    end

    def set_instructions
        @instructions[:LDA] = 8
    end

    def load_program(p)
        @program = p
    end

    def run 
        @program.each_line { |line| self.parse_line line }
    end

    def parse_line(line)
        code = line.split(/\s/)
        fspec = code.last.split(/^\d{1,4}/).last or nil
        self.parse_code code.first, code.last, fspec
    end

    def parse_code(instruction, memory, fspec)
        start = 0
        stop  = 5
        if not fspec.nil? and not fspec.empty?
            start = fspec.split(/:/).first.sub('(', '').to_i
            stop  = fspec.split(/:/).last.sub(')', '').to_i
        end
        case instruction
        when "LDA"
            @reg_a = self.load_register(memory.to_i, start, stop)
        when "LDX"
            @reg_x = self.load_register(memory.to_i, start, stop)
        when "LD1"
            @reg_i1 = self.load_register(memory.to_i, start, stop)
        when "LD2"
            @reg_i2 = self.load_register(memory.to_i, start, stop)
        when "LD3"
            @reg_i3 = self.load_register(memory.to_i, start, stop)
        when "LD4"
            @reg_i4 = self.load_register(memory.to_i, start, stop)
        when "LD5"
            @reg_i5 = self.load_register(memory.to_i, start, stop)
        when "LD6"
            @reg_i6 = self.load_register(memory.to_i, start, stop)
        when "LDAN"
            @reg_a = self.load_register(memory.to_i, start, stop)
            @reg_a[0] = self.opposite_sign(@reg_a[0])
        when "LDXN"
            @reg_x = self.load_register(memory.to_i, start, stop)
            @reg_x[0] = self.opposite_sign(@reg_x[0])
        when "STA"
            temp = self.store_register('A', start, stop)
            temp.each_with_index { |n,i| 
                if n.nil?
                    temp[i] = @mem[memory.to_i][i]
                end
            }
            @mem[memory.to_i] = temp
        end
    end

    def opposite_sign(sign)
        case sign
        when "+"
            return "-"
        when "-"
            return "+"
        end
    end

    def store_register(reg, start, stop)
        temp = Array.new(6)
        case reg
        when 'A'
            temp[start..stop] = @reg_a[start..stop]
            return temp
        end
    end

    def load_register(location, start, stop, size=6)
        reg = Array.new(size)
        temp = Array.new(size)
        temp[start..stop] = @mem[location][start..stop]
        sign = '+'
        
        if start == 0 and stop < 5 and stop > 0
            sign = temp[0]
            temp_start = size - temp.compact.count - 1
            temp_stop  = temp.compact.count - 1
            reg_start = stop
            reg_stop  = temp.count - 1
        elsif start > 0 and stop < 5
            temp_start = start
            temp_stop = stop
            reg_start = size - temp.compact.count
            reg_stop = temp.size - 1
        else
            reg_start = start
            reg_stop  = stop
            temp_start = start
            temp_stop = stop
        end
        reg[0] = sign
        reg[reg_start..reg_stop] = temp[temp_start..temp_stop]
        self.check_register(reg)
    end

    def check_register(reg)
        reg.collect { |i| 
            if i.nil?
                0
            else
                i
            end
        }
    end

    def set_mem(loc, a)
        @mem[loc] = a
    end
end
