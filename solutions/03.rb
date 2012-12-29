#!/usr/bin/env ruby

class Expr
  def self.build(sexpression)
    if sexpression.length == 2
      Unary.build(sexpression)
    elsif sexpression.length == 3
      Binary.build(sexpression)
    end
  end

  def initialize(sexpression)
    @sexpression = sexpression
  end

  def ==(other)
    @sexpression == other.sexpression
  end
end


class Unary < Expr
  attr_reader :operation, :argument

  def +(argument)
    @argument + argument
  end

  def self.build(expr_tree)
    case expr_tree[0]
      when :-
        Negation.new([expr_tree[0], Expr.build(expr_tree[1])])
      when :sin
        Sine.new([expr_tree[0], Expr.build(expr_tree[1])])
      when :cos
        Cosine.new([expr_tree[0], Expr.build(expr_tree[1])])
      when :variable
        Variable.new([expr_tree[0], expr_tree[1]])
      when :number
        Number.new([expr_tree[0], expr_tree[1]])
    end
  end

  def initialize(sexpression)
    @sexpression = sexpression
    @operation, @argument = sexpression
  end

  def ==(expr)
    expr.operation == @operation and
        expr.argument == @argument
  end

  private
  def exact?
    not @sexpression.flatten.include?(:variable)
  end

  def operands
    [self]
  end
end


class Binary < Expr
  attr_reader :operation, :left_operand, :right_operand
  def self.build(expr_tree)
    Binary.new(expr_tree[0], Expr.build(expr_tree[1]), Expr.build(expr_tree[2]))
  end

  def initialize(*expr_tree)
    @operation, @left_operand, @right_operand = expr_tree[0], expr_tree[1], expr_tree[2]
  end

  def evaluate(environment = {})
    @left_operand.evaluate(environment).send(@operation, @right_operand.evaluate(environment))
  end

  def ==(expr)
    expr.operation == @operation and
        expr.left_operand == @left_operand and expr.right_operand == @right_operand
  end

  def simplify
    if @left_operand.exact? and @right_operand.exact?
      [:number, evaluate]
    else
      simplify_each
    end
  end

  private
  def simplify_each
    @left_operand.operands.product(@right_operand.operands).each do |binary_elements|
      binary_elements[0].send(@operation, binary_elements[1])
    end
  end

  def operands
    [@left_operand, @right_operand]
  end

  def exact?
    @left_operand.exact? and @right_operand.exact?
  end
end


class Number < Unary
  def evaluate(environment = {})
    @argument
  end

  def simplify
    @sexpression
  end

  def exact?
    true
  end
end


class Variable < Unary
  def evaluate(environment = {})
    environment[@argument]
  end

  def simplify
    @sexpression
  end

  def exact?
    false
  end
end


class Negation < Unary
  def evaluate(environment = {})
    -(@argument.evaluate(environment))
  end

  def simplify
    if exact?
      [:-, evaluate]
    else
      @sexpression
    end
  end
end


class Sine < Unary
  def evaluate(environment = {})
    Math.sin(@argument.evaluate(environment))
  end

  def simplify
    if exact?
      [:sin, evaluate]
    else
      @sexpression
    end
  end
end


class Cosine < Unary
  def evaluate(environment = {})
    Math.cos(@argument.evaluate(environment))
  end

  def simplify
    if exact?
      [:cos, evaluate]
    else
      @sexpression
    end
  end
end
