module Git
  class Lib
    def tag_delete(tag_name)
      command('tag', ['-d', tag_name])
    end
  end
end