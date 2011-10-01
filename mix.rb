class CPU
    attr_accessor :registers, :overflow_toggle, :comparison, :mem, :instructions, :program, :mix_charset
    
    MIX_OK     = 0
    MIX_HALT   = 1
    MIX_ERROR  = 2
    MIX_IOWAIT = 3
        
    def initialize
        @registers = { 'A' => nil, 'X' => nil, 'I1' => nil, 'I2' => nil, 'I3' => nil, 'I4' => nil, 'I5' => nil, 'I6' => nil, 'J' => nil }
        @mix_charset = " ABCDEFGHI^JKLMNOPQR^^STUVWXYZ0123456789.,()+-*/=\$<>@;:'"; # ^ are placeholders and not valid characters. 
        self.reset
    end

    def reset
        @registers['A']  = ['+', 0, 0, 0, 0, 0]
        @registers['X']  = ['+', 0, 0, 0, 0, 0]
        @registers['I1'] = ['+', 0, 0]
        @registers['I2'] = ['+', 0, 0]
        @registers['I3'] = ['+', 0, 0]
        @registers['I4'] = ['+', 0, 0]
        @registers['I5'] = ['+', 0, 0]
        @registers['I6'] = ['+', 0, 0]
        @registers['J']  = ['+', 0, 0]
        @overflow_toggle = false
        @comparison = { :equal => false, :less => false, :greater => false }
        
        new_mem = Array.new(4000)
        @mem = new_mem.collect { |x| ['+', 0, 0, 0, 0, 0] }
        @status = MIX_OK
    end

    def step
        if @status == MIX_IOWAIT
            return false
        elsif @status != MIX_OK
            return false
        end
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
            @registers['A'] = self.read_mem(memory.to_i, start, stop)
        when "LDX"
            @registers['X'] = self.read_mem(memory.to_i, start, stop)
        when "LD1"
            @registers['I1'] = self.read_mem(memory.to_i, start, stop)
        when "LD2"
            @registers['I2'] = self.read_mem(memory.to_i, start, stop)
        when "LD3"
            @registers['I3'] = self.read_mem(memory.to_i, start, stop)
        when "LD4"
            @registers['I4'] = self.read_mem(memory.to_i, start, stop)
        when "LD5"
            @registers['I5'] = self.read_mem(memory.to_i, start, stop)
        when "LD6"
            @registers['I6'] = self.read_mem(memory.to_i, start, stop)
        when "LDAN"
            @registers['A'] = self.read_mem(memory.to_i, start, stop)
            @registers['A'][0] = self.opposite_sign(@registers['A'][0])
        when "LDXN"
            @registers['X'] = self.read_mem(memory.to_i, start, stop)
            @registers['X'][0] = self.opposite_sign(@registers['X'][0])
        when "STA"
            self.set_mem(memory.to_i, @registers['A'].clone, start, stop)
        when "STX"
            self.set_mem(memory.to_i, @registers['X'].clone, start, stop)
        when "ST1"
            self.set_mem(memory.to_i, @registers['I1'].clone, start, stop)
        when "ST2"
            self.set_mem(memory.to_i, @registers['I2'].clone, start, stop)
        when "ST3"
            self.set_mem(memory.to_i, @registers['I3'].clone, start, stop)
        when "ST4"
            self.set_mem(memory.to_i, @registers['I4'].clone, start, stop)
        when "ST5"
            self.set_mem(memory.to_i, @registers['I5'].clone, start, stop)
        when "ST6"
            self.set_mem(memory.to_i, @registers['I6'].clone, start, stop)
        when "STJ"
            self.set_mem(memory.to_i, @registers['J'].clone, start, stop)
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

    def set_mem(loc, word, l=0, r=5)
        if loc < 0 or loc > 3999
            @status = MIX_ERROR
            @message = "Writing to invalid memory location: #{loc}"
            return 
        end
        
        r.downto(l) { |i|
            if i > 0
                @mem[loc][i] = word.pop
            end
            
            if i == 0
                if word[0] and (word[0] == '+' or word[0] == '-')
                    @mem[loc][0] = word[0]
                else
                    @mem[loc][0] = '+'
                end
            end
        }
    end

    def read_mem(loc, l=0, r=5)
        if loc < 0 or loc > 3999
            @status = MIX_ERROR
            @message = "Reading at invalid memory location: #{loc}"
            return
        end
        ret = @mem[loc].clone
        if l == 0
            l = 1
        else
            ret[0] = '+'
        end

        5.downto(1) { |i|
            if r >= l
                ret[i] = ret[r]
            else
                ret[i] = 0
            end
            r -= 1
        }
        ret
    end

    def mix_char(code)
        return false if code < 0 or code >= @mix_charset.size - 1
        @mix_charset[code..code]
    end

    def mix_char_code(char)
        return false if char == '^'
        @mix_charset.index(char)
    end
end
