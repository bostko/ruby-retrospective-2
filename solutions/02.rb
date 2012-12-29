#!/usr/bin/env ruby

class Song
  attr_reader :name, :artist, :album

  def initialize(name, artist, album)
    @name, @artist, @album = name, artist, album
  end
end


class Collection
  attr_reader :songs
  private
  def initialize(songs)
    @songs = songs
  end

  public

  def adjoin(collection)
    Collection.new(collection.songs & @songs)
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

  def names
    @songs.map { |song| song.name }
  end

  def artists
    @songs.map { |song| song.artist }
  end

  def albums
    @songs.map { |song| song.album }
  end

  def filter(criteria)
    @songs.select do |song|
      criteria.match(song)
    end
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

  private
  def match(song)
    @operation ? match_operation :
        match_single(song)
  end

  def match_operation
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
end
