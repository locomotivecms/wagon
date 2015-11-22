module Locomotive::Wagon

  module SpinnerConcern

    # http://stackoverflow.com/questions/10262235/printing-an-ascii-spinning-cursor-in-the-console
    def show_wait_spinner(sentence = nil, fps = 10)
      chars = %w[| / - \\]
      delay = 1.0/fps
      iter  = 0

      spinner = Thread.new do
        print sentence if sentence

        while iter do  # Keep spinning until told otherwise
          print chars[(iter += 1) % chars.length]
          sleep delay
          print "\b"
        end
      end

      yield.tap {       # After yielding to the block, save the return value
        iter = false   # Tell the thread to exit, cleaning up after itself…
        spinner.join   # …and wait for it to do so.
      }                # Use the block's return value as the method's
    end

  end

end
