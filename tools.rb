#-----------------------------------------------------------------------------#
#   tools.rb                                                                  #
#                                                                             #
#   Copyright (c) 2015, Seventy Four, Inc.                                    #
#   All rights reserved.                                                      #
#-----------------------------------------------------------------------------#



module Tools
  module Ruby
    def self.common(callees, callee)
      return if callees.include?(callee)
      message = 'this method can only be called as '
      fail message << callees.map { |c| "##{c}" } * ', '
    end
  end
end
