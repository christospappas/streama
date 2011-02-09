module Streama
  
  class StreamaError < StandardError
  end
  
  class UndefinedActivity < StreamaError
  end
  
  class UndefinedData < StreamaError
  end
  
  class UndefinedField < StreamaError
  end
  
end