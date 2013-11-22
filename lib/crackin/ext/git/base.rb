module Git
  class Base
    def tag_delete(tag_name)
      tag = tag(tag_name)
      self.lib.tag_delete(tag_name)
      tag
    end

    def branch_current
      self.lib.branch_current
    end
  end
end