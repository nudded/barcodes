require 'barcodes/symbology/standard'

module Barcodes
  module Symbology
    class Code93 < Standard
      def self.charset
        [
          "0","1","2","3","4","5","6","7","8","9",
          "A","B","C","D","E","F","G","H","I","J",
          "K","L","M","N","O","P","Q","R","S","T",
          "U","V","W","X","Y","Z","-","."," ","$",
          "/","+","%","*","\xFC","\xFD","\xFE","\xFF"
        ].collect {|c| c.bytes.to_a[0] }
      end
      
      def self.valueset
        [
          "100010100","101001000","101000100","101000010",
          "100101000","100100100","100100010","101010000",
          "100010010","100001010","110101000","110100100",
          "110100010","110010100","110010010","110001010",
          "101101000","101100100","101100010","100110100",
          "100011010","101011000","101001100","101000110",
          "100101100","100010110","110110100","110110010",
          "110101100","110100110","110010110","110011010",
          "101101100","101100110","100110110","100111010",
          "100101110","111010100","111010010","111001010",
          "101101110","101110110","110101110","101011110",
          "100100110","111011010","111010110","100110010"
        ]
      end
      
      def initialize(args={})
        super(args)
        
        @start_character = '*'
        @stop_character = '*'
      end
      
      def caption_data
        @start_character + @data + @stop_character
      end
      
      def formatted_data
        checksum = self.checksum
        unless checksum.nil?
          @start_character + @data + checksum + @stop_character
        end
      end
      
      def checksum
        if self.valid?
          c_value = self._checksum(@data, 20)
          k_value = self._checksum(@data + c_value, 15)
          return c_value + k_value
        end
      end
      
      protected
      
      def _checksum(data, weight_max)
        sum = 0
        weight = 1
        data.reverse.each_byte do |char|
          if char == 255 || char == 254 || char == 253 || char == 252
            case char
            when 252
              sum += 43
            when 253
              sum += 44
            when 254
              sum += 45
            when 255
              sum += 46
            end
          else
            if ('0'..'9').include? char.chr
              sum += weight * char.chr.to_i
            elsif ('A'..'Z').include? char.chr
              sum += ('A'..'Z').to_a.index(char.chr) + 10
            else
              case char.chr
              when '-'
                sum += 36
              when '.'
                sum += 37
              when ' '
                sum += 38
              when '$'
                sum += 39
              when '/'
                sum += 40
              when '+'
                sum += 41
              when '%'
                sum += 42
              end
            end
          end
          if weight <= weight_max
            weight += 1
          else
            weight = 1
          end
        end
        
        value = sum % 47
        
        if (0..9).include? value
          return value.to_s
        elsif value >= 10 && value < 36
          return ('A'..'Z').to_a.fetch(value - 10)
        else
          case value
          when 36
            return '-'
          when 37
            return '.'
          when 38
            return ' '
          when 39
            return '$'
          when 40
            return '/'
          when 41
            return '+'
          when 42
            return '%'
          when 43
            return "\xFC"
          when 44
            return "\xFD"
          when 45
            return "\xFE"
          when 46
            return "\xFF"
          end
        end
      end
    end
  end
end