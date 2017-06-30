# cgen
# lumiknit

module cgen
#--------------------------------------
# Global
#--------------------------------------
	@@initialized = false
	@@n_bits = 32
	@@ptr_size = 4

	def initialize
		case @@n_bits
		when 32
			@@ptr_size = 4
		when 64
			@@ptr_size = 8
		end
	end

	class Object
		attr_accessor :G
		def initialize G
			@G = G
		end
	end

#--------------------------------------
# Variable
#--------------------------------------
	class Var < Object
		attr_reader :type, :pointer, :name

		def initialize G, type, pointer, name, array_size=nil
			super G
			@type = type
			@pointer = pointer
			@name = name
			@array_size = array_size
		end
	end

#--------------------------------------
# Type
#--------------------------------------
	class Type
		attr_reader :name
		def initialize G, name
			super G
			@name = name
		end
	end

	class StructType < Type
		attr_accessor :name, :list
		def initialize G, name
			super G, name
			@list = []
		end

		def << var
			if var.is_a? Var
				@list << var
			end
		end
	end

	class Struct < StructType
	end

	class Union < StructType
	end

#--------------------------------------
# Enum
#--------------------------------------
	class Enum < Object
		attr_accessor :name, :list
		def initialize G, name = nil, list
			super G
			@name = name
			@list = list
		end

		def toString
		end
	end


#--------------------------------------
# Code
#--------------------------------------
	class Code < Object
		def initialize G
			super G
		end

		def toString
			return ''
		end
	end

	# A = B
	class CSet < Code
		attr_accessor :left, :right
		def initialize G, left, right
			super G
			@left = left
			@right = right
		end

		def toString
			return @left.toString + " = " + @right.toString
		end
	end

	# Mono Operator
	# - * & ~ !
	class CMonoOp < Code
		attr_accessor :right, :op
		def initialize G, right, op
			super G
			@right = right
			@op = op
		end
	end

	# Binary Operator
	class CBinOp < Code
		attr_accessor :left, :right, :op
		def initialize G, left, right, op
			super G
			@left = left
			@right = right
			@op = op
		end
	end

	class C

	# else, break, return, continue, ...
	class CReserved < Code
		attr_accessor :word, :args
		def initialize G, word, args
			super G
			@word = word
			@args = args
		end
	end

	# (a, b, c)
	class CCall < Code
		attr_accessor :args
		def initialize G, args
			super G
			@args = args
		end
	end

	# Access (.)
	class CAccess < CBinOP
		attr_accessor :left, :right
		def initialize G, left, right
			super G
			@left = left
			@right = right
		end
	end

	# Block(while, if)
	class CCondition < Code
		attr_accessor :word, :cond, :block
		def initialize G, word, cond, block
			super G
			@word = word
			@cond = cond
			@block = block
		end
	end

	# for
	class CFor < Code
		attr_accessor :from, :cond, :inc, :block
		def initialize G, from, cond, inc, block
			super G
			@from = from
			@cond = cond
			@inc = inc
			@block = block
		end
	end

	#switch
	class CSwitch < Code
		attr_accessor :var, :list
		def initialize G, var, list
			super G
			@var = var
			@list = list
		end
	end

	# case
	class CSwitch < Code
		attr_accessor :key, :block
		def initialize G, key, block
			super G
			@key = key
			@block = block
		end
	end

#--------------------------------------
# Context(Function)
#--------------------------------------
	class Context < Object
		def initialize G, outer = nil
			super G
			@outer = outer
			@n_args = 0
			@local = []
			@code = []
		end

		def pushLocal var
			raise 'Arg is not class Var' unless var.is_a? Var
			flag = true
			@local.each {|x|
				if x.name == var.name then
					flag = false
					break
				end
			}
			@local << var if flag
		end

		def pushCode 
		end
	end

	class Function < Context
		def initialize
			@ret = 'void'
		end
	end

#--------------------------------------
# Generator
#--------------------------------------
	class Generator
		def initialize
			@global = Context.new self
			@functions = []

			initializeTypes
		end

		def newType name
			return Type.new self, name
		end

		def newStruct name
			return Struct.new self, name
		end

		def newUnion name
			return Union.new self, name
		end

		def initializeTypes
			# Initialize Default Types
			@type = []
			@type << newType 'char' << newType 'short' << newType 'int' << newType 'long long'
			@type << newType 'float' << newType 'double' << newType 'void'
		end
	end
end
