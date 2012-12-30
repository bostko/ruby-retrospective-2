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

  def filter(creteria)
    Collection.new( @songs.select{ |song| creteria.call(song) } )
  end

  def adjoin(collection)
    list_of_songs = @songs
    collection.each{ |song| list_of_songs << song }
    Collection.new( list_of_songs )
  end
end


class Criteria
  def initialize(filter)
    @filter = filter
  end

  def Criteria.name(name)
    Criteria.new( Proc.new{ |song| song.name == name } )
  end

  def Criteria.artist(artist)
    Criteria.new( Proc.new{ |song| song.artist == artist } )
  end

  def Criteria.album(album)
    Criteria.new( Proc.new{ |song| song.album == album } )
  end

  def !
    Criteria.new( Proc.new{ |song| not call(song) } )
  end

  def &(other)
    Criteria.new( Proc.new{ |song| call(song) and other.call(song) } )
  end

  def |( other )
    Criteria.new( Proc.new{ |song| call(song) or other.call(song) } )
  end

  def call( song )
    @filter.call( song )
  end
end
