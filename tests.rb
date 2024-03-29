require 'test/unit'
require 'mix'

class CPUTest < Test::Unit::TestCase
    def setup
        @cpu = CPU.new
    end
    
    def test_mix_char
        assert_equal(' ', @cpu.mix_char(0), 'mix_char 0 is not equal to space.')
        assert_equal('A', @cpu.mix_char(1), 'mix_char 1 is not equal to A.')
        assert_equal('@', @cpu.mix_char(52), 'mix_char 52 is not equal to @.')
        assert_equal('[', @cpu.mix_char(20), 'mix_char 20 is not equal to [.')
    end

    def test_mix_char_code
        assert_equal(52, @cpu.mix_char_code('@'), 'mix_char_code @ is not equal to 52.')
    end

    def test_lda
        @cpu.set_mem 2000, ['-', 8, 0, 3, 5, 4]
        @cpu.load_program('LDA 2000')
        @cpu.run
        assert_equal(['-',8,0,3,5,4], @cpu.registers['A'], 'Testing without Fspec. Register A is not equal to expected result.')

        @cpu.load_program('LDA 2000(1:5)')
        @cpu.run
        assert_equal(['+',8,0,3,5,4], @cpu.registers['A'], 'Testing Fspec 1:5. Register A is not equal to expected result.')

        @cpu.load_program('LDA 2000(3:5)')
        @cpu.run
        assert_equal(['+',0,0,3,5,4], @cpu.registers['A'], 'Testing Fspec 3:5. Register A is not equal to expected result.')

        @cpu.load_program('LDA 2000(0:3)')
        @cpu.run
        assert_equal(['-',0,0,8,0,3], @cpu.registers['A'], 'Testing Fspec 0:3. Register A is not equal to expected result.')

        @cpu.load_program('LDA 2000(4:4)')
        @cpu.run
        assert_equal(['+',0,0,0,0,5], @cpu.registers['A'], 'Testing Fspec 4:4. Register A is not equal to expected result.')

        @cpu.load_program('LDA 2000(0:0)')
        @cpu.run
        assert_equal(['-',0,0,0,0,0], @cpu.registers['A'], 'Testing Fspec 0:0. Register A is not equal to expected result.')

        @cpu.load_program('LDA 2000(1:1)')
        @cpu.run
        assert_equal(['+',0,0,0,0,8], @cpu.registers['A'], 'Testing Fspec 1:1. Register A is not equal to expected result.') 
    end

    def test_ldx
        @cpu.set_mem 2000, ['-', 8, 0, 3, 5, 4]
        @cpu.load_program('LDX 2000')
        @cpu.run
        assert_equal(['-',8,0,3,5,4], @cpu.registers['X'], 'Testing without Fspec. Register X is not equal to expected result.')

        @cpu.load_program('LDX 2000(1:5)')
        @cpu.run
        assert_equal(['+',8,0,3,5,4], @cpu.registers['X'], 'Testing Fspec 1:5. Register X is not equal to expected result.')

        @cpu.load_program('LDX 2000(3:5)')
        @cpu.run
        assert_equal(['+',0,0,3,5,4], @cpu.registers['X'], 'Testing Fspec 3:5. Register X is not equal to expected result.')

        @cpu.load_program('LDX 2000(0:3)')
        @cpu.run
        assert_equal(['-',0,0,8,0,3], @cpu.registers['X'], 'Testing Fspec 0:3. Register X is not equal to expected result.')

        @cpu.load_program('LDX 2000(4:4)')
        @cpu.run
        assert_equal(['+',0,0,0,0,5], @cpu.registers['X'], 'Testing Fspec 4:4. Register X is not equal to expected result.')

        @cpu.load_program('LDX 2000(0:0)')
        @cpu.run
        assert_equal(['-',0,0,0,0,0], @cpu.registers['X'], 'Testing Fspec 0:0. Register X is not equal to expected result.')

        @cpu.load_program('LDX 2000(1:1)')
        @cpu.run
        assert_equal(['+',0,0,0,0,8], @cpu.registers['X'], 'Testing Fspec 1:1. Register X is not equal to expected result.') 
    end

    def test_ldan
        @cpu.set_mem 2000, ['-', 8, 0, 3, 5, 4]
        @cpu.load_program('LDAN 2000')
        @cpu.run
        assert_equal(['+',8,0,3,5,4], @cpu.registers['A'], 'Testing without Fspec.')

        @cpu.load_program('LDAN 2000(1:5)')
        @cpu.run
        assert_equal(['-',8,0,3,5,4], @cpu.registers['A'], 'Testing Fspec 1:5.')

        @cpu.load_program('LDAN 2000(3:5)')
        @cpu.run
        assert_equal(['-',0,0,3,5,4], @cpu.registers['A'], 'Testing Fspec 3:5. Register A is not equal to expected result.')

        @cpu.load_program('LDAN 2000(0:3)')
        @cpu.run
        assert_equal(['+',0,0,8,0,3], @cpu.registers['A'], 'Testing Fspec 0:3. Register A is not equal to expected result.')

        @cpu.load_program('LDAN 2000(4:4)')
        @cpu.run
        assert_equal(['-',0,0,0,0,5], @cpu.registers['A'], 'Testing Fspec 4:4. Register A is not equal to expected result.')

        @cpu.load_program('LDAN 2000(0:0)')
        @cpu.run
        assert_equal(['+',0,0,0,0,0], @cpu.registers['A'], 'Testing Fspec 0:0. Register A is not equal to expected result.')

        @cpu.load_program('LDAN 2000(1:1)')
        @cpu.run
        assert_equal(['-',0,0,0,0,8], @cpu.registers['A'], 'Testing Fspec 1:1. Register A is not equal to expected result.') 
    
    end

    def test_sta
        @cpu.set_mem 2000, ['-',1,2,3,4,5]
        @cpu.registers['A'] = ['+',6,7,8,9,0]
        
        @cpu.load_program('STA 2000')
        @cpu.run
        assert_equal(['+',6,7,8,9,0], @cpu.mem[2000], 'Testing without Fspec.')

        @cpu.set_mem 2000, ['-',1,2,3,4,5]
        @cpu.load_program('STA 2000(1:5)')
        @cpu.run
        assert_equal(['-',6,7,8,9,0], @cpu.mem[2000], 'Testing with Fspec 1:5.')

        @cpu.set_mem 2000, ['-',1,2,3,4,5]
        @cpu.load_program('STA 2000(5:5)')
        @cpu.run
        assert_equal(['-',1,2,3,4,0], @cpu.mem[2000], 'Testing with Fspec 5:5.')

        @cpu.set_mem 2000, ['-',1,2,3,4,5]
        @cpu.load_program('STA 2000(2:2)')
        @cpu.run
        assert_equal(['-',1,0,3,4,5], @cpu.mem[2000], 'Testing with Fspec 2:2.')
        
        @cpu.set_mem 2000, ['-',1,2,3,4,5]
        @cpu.load_program('STA 2000(2:3)')
        @cpu.run
        assert_equal(['-',1,9,0,4,5], @cpu.mem[2000], 'Testing with Fspec 2:3.')
    end

    def test_add
        @cpu.registers['A'] = ['+',12,34,1,1,50]
        @cpu.set_mem 1000, ['+', 1, 00, 5, 0, 50]
        @cpu.load_program('ADD 1000')
        @cpu.run
        assert_equal(['+', 13, 34, 6, 2, 00], @cpu.registers['A'], 'Testing ADD.')
    end

    def test_set_mem_bad_location
        @cpu.set_mem 5000, ['+', 1, 2, 3, 4, 5]
        assert_equal(@cpu.status, 2, 'Testing bad location status')
        assert_equal(@cpu.message, "Writing to invalid memory location: 5000", 'Testing bad location message')
    end

    def test_read_mem_bad_location
        a = @cpu.read_mem 5000
        assert_equal(@cpu.status, 2, 'Testing bad location status')
        assert_equal(@cpu.message, "Reading at invalid memory location: 5000")
    end
end
