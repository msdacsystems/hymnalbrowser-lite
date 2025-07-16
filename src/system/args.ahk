/**
 * * AppArgs Class
 * -----------------
 * Parses command line arguments for the application. 
 * Supports switches like -s/--slideshow and -q/--query.
 * 
 * (c) 2022-2025 MSDAC Systems
 * @author Ken Verdadero <dev@kenverdadero.com>
 * Written 2025-07-16
 */
class AppArgs {
  /**
   * Parses the command line arguments and returns them as an object.
   * @returns {Object} An object containing the parsed arguments.
   */
  static Parse() {
    args := {
      StartInSlideshow: false,
      Query: ""
    }

    for i, arg in A_Args {
      switch arg {
        case "-s", "--slideshow":
          args.StartInSlideshow := true
        case "-q", "--query":
          nextIndex := i + 1
          if (nextIndex <= A_Args.Length)
            args.Query := A_Args[nextIndex]
      }
    }
    return args
  }
}
