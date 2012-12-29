#!/usr/bin/env ruby

class Song
  attr_reader :name, :artist, :album

  def initialize(name, artist, album)
    @name, @artist, @album = name, artist, album
  end
end


class Collection
  include Enumerable

  attr_reader :songs
  private
  def initialize(songs)
    @songs = songs
  end

  public
  def adjoin(collection)
    Collection.new(collection.songs | @songs)
  end

  def each(&block)
    @songs.each(&block)
  end

  def self.parse(text)
    song_array = text.lines.each_slice(4).inject([]) do |collection, row|
      collection << Song.new(row[0].strip, row[1].strip, row[2].strip)
    end

    Collection.new(song_array)
  end

  def artists
    @songs.map(&:artist).uniq
  end

  def names
    @songs.map(&:name).uniq
  end

  def albums
    @songs.map(&:album).uniq
  end

  def filter(criteria)
    Collection.new(@songs.select { |song| criteria.match(song) })
  end
end


class Criteria
  def self.name(name)
    Criteria.new(:name => name)
  end

  def self.artist(artist)
    Criteria.new(:artist => artist)
  end

  def self.album(album)
    Criteria.new(:album => album)
  end

  def initialize(search)
    @search = search
  end

  def &(other)
    @operation = :&
    @other = other
    self
  end

  def |(other)
    @operation = :|
    @other = other
    self
  end

  def !
    @operation = :!
    self
  end

  def match(song)
    @operation ? match_operation(song) :
        match_single(song)
  end

  protected
  def match_operation(song)
    case @operation
      when :& then match_single(song) && @other.match_single(song)
      when :| then match_single(song) || @other.match_single(song)
      when :! then ! match_single(song)
    end
  end

  def match_single(song)
    @search[:name] && @search[:name] == song.name ||
        @search[:artist] && @search[:artist] == song.artist ||
        @search[:album] &&  @search[:album] == song.album
  end

  def add(songs)
    @songs + songs
  end
end
