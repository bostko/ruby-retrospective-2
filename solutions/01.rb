#!/usr/bin/env ruby

class Integer
  def prime_divisors
    factors = []
    d = 2

    tmp = self
    while tmp > 1
      while tmp % d == 0
        factors << d unless factors.last == d
        tmp /= d
      end
      d += 1
    end
    factors
  end
end


class Range
  def fizzbuzz
    res = []
    each do |x|
      if x % 3 == 0 and x % 5 == 0
        res << :fizzbuzz
      elsif x % 3 == 0
        res << :fizz
      elsif x % 5 == 0
        res << :buzz
      else
        res << x
      end
    end
    res
  end
end


class Hash
  def group_values
    new_hash = Hash.new { |h,k| h[k] = [] }
    each do |k, v|
      new_hash[v] << k
    end
    new_hash
  end
end


class Array
  def densities
    freq_tbl = Hash.new(0)
    each do |x|
      freq_tbl[x] += 1
    end

    res = []
    each do |x|
      res << freq_tbl[x]
    end
    res
  end
end