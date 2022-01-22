var documenterSearchIndex = {"docs":
[{"location":"api/#api_section","page":"API","title":"API","text":"","category":"section"},{"location":"api/","page":"API","title":"API","text":"CurrentModule = SolverLogging","category":"page"},{"location":"api/#The-Logger","page":"API","title":"The Logger","text":"","category":"section"},{"location":"api/","page":"API","title":"API","text":"Logger","category":"page"},{"location":"api/#SolverLogging.Logger","page":"API","title":"SolverLogging.Logger","text":"SolverLogger.Logger\n\nA logger designed to print tabulated data that can be updated at any point.  It supports varying verbosity levels, each including all of the information  from previous levels. \n\nConstructor\n\nSolverLogger.Logger(io=stdout; opts...)\nSolverLogger.Logger(filename; opts...)\n\nThe constructor can take either an IO object or a filename, in which case it will  be opened with write permissions, replacing any existing contents.\n\nThe keyword arguments opts are one of the following:\n\ncurlevel Current verbosity level of the solver. A non-negative integer.\nfreq A non-negative integer specifying how often the header row should be printed.\nheaderstyle A Crayon specifying the style of the header.\nlinechar A Char that is used for the deliminating row underneath the header. Set to \u0000 to not print a row below the header.\nenable Enabled/disabled state of the logger at construction.\n\nTypical Usage\n\nThe fields to be printed are specified before use via setentry. Here the user can specify properties of the field such as the width of the column, format  specifications (such as number of decimal places, numeric format, alignment, etc.), column index, and even conditional formatting via a ConditionalCrayon. Each field is assigned a fixed verbosity level, and is only printed if the current verbosity level of the logger, set via setlevel! is greater than or equal  to the level of the field.\n\nOnce all the fields for the logger have been specified, typical usage is via the  @log macro:\n\n@log logger \"iter\" 1\n@log logger \"cost\" cost * 10  # supports expressions\n@log logger \"alpha\" alpha\n@log logger alpha             # shortcut for the previous\n\nAll calls to @log overwrite any previous data. Data is only stored in the logger  if the field is active at the current verbosity.\n\nTo print the log, the easiest is via the printlog function, which will  automatically print the header rows for you, at the frequency specified by  logger.opts.freq. The period can be reset (printing a header at the next call to  printlog) via resetcount!. For more control, the header and rows can  be printed directly via printheader and printrow.\n\nThe logger can be completely reset via resetlogger!.\n\nEnabling / Disabling\n\nThe logger can be enable/disabled via SolverLogging.enable and SolverLogging.disable. This overwrites the verbosity level.\n\nDefault logger\n\nMost methods that take a SolverLogging.Logger as the first argument (including @log) support omitting the logger, in which case the default logger stored in the SolverLogging module is used.\n\n\n\n\n\n","category":"type"},{"location":"api/#Main-Methods","page":"API","title":"Main Methods","text":"","category":"section"},{"location":"api/","page":"API","title":"API","text":"printlog\nprintheader\nprintrow\nformheader\nformrow\ngetlevel\nsetlevel!\nresetcount!\nresetlogger!","category":"page"},{"location":"api/#SolverLogging.printlog","page":"API","title":"SolverLogging.printlog","text":"printlog(logger)\n\nPrints the data currently in the logger, automatically printing the header  at the frequency specified by logger.opts.freq.\n\nThe period of the header can be reset using resetcount!.\n\n\n\n\n\n","category":"function"},{"location":"api/#SolverLogging.printheader","page":"API","title":"SolverLogging.printheader","text":"printheader(logger)\n\nPrints the header row(s) for the logger, including only the entries that are active at the current verbosity level. The style of the header can be changed via  logger.opts.headerstyle, which is a Crayon that applies to the entire header. The repeated character under the header can be specified via logger.opts.linechar. This value can be set to the null character \u0000 if this line should be excluded.\n\n\n\n\n\n","category":"function"},{"location":"api/#SolverLogging.printrow","page":"API","title":"SolverLogging.printrow","text":"printrow(logger)\n\nPrints the data currently stored in the logger. Any entries with a  ConditionalCrayon will be printed in the specified color. Only prints the data for the current verbosity level.\n\n\n\n\n\n","category":"function"},{"location":"api/#SolverLogging.formheader","page":"API","title":"SolverLogging.formheader","text":"formheader(logger)\n\nOutputs the header as a string\n\n\n\n\n\n","category":"function"},{"location":"api/#SolverLogging.formrow","page":"API","title":"SolverLogging.formrow","text":"formrow(logger)\n\nOutputs the data for the current verbosity level as a string.\n\n\n\n\n\n","category":"function"},{"location":"api/#SolverLogging.getlevel","page":"API","title":"SolverLogging.getlevel","text":"getlevel(logger)\n\nGets the current verbosity level for the logger.\n\n\n\n\n\n","category":"function"},{"location":"api/#SolverLogging.setlevel!","page":"API","title":"SolverLogging.setlevel!","text":"setlevel!(logger, level)\n\nSet the verbosity level for the logger. High levels prints more information. Returns the previous verbosity level.\n\n\n\n\n\n","category":"function"},{"location":"api/#SolverLogging.resetcount!","page":"API","title":"SolverLogging.resetcount!","text":"resetcount!(logger)\n\nResets the row counter such that the subsequent call to printlog will  print a header row, and start the count from that point.\n\n\n\n\n\n","category":"function"},{"location":"api/#SolverLogging.resetlogger!","page":"API","title":"SolverLogging.resetlogger!","text":"resetlogger!(logger)\n\nResets the logger to the default configuration. All current data will be lost, including all fields and default formats.\n\n\n\n\n\n","category":"function"},{"location":"api/#Defining-Entries","page":"API","title":"Defining Entries","text":"","category":"section"},{"location":"api/","page":"API","title":"API","text":"setentry\nset_default_format","category":"page"},{"location":"api/#SolverLogging.setentry","page":"API","title":"SolverLogging.setentry","text":"setentry(logger, name::String, type; kwargs...)\n\nUsed to add a new entry/field or modify an existing entry/field in the logger.\n\nAdding a new entry\n\nSpecify a unique name to add a new entry to the logger. The type is used to provide  reasonable formatting defaults and must be included. The keyword arguments control  the behavior/formatting of the field:\n\nfmt A C-style format string used to control the format of the field\nindex Column for the entry in the output. Negative numbers insert from the end.\nlevel Verbosity level for the entry. A higher level will be printed less often.       Level 0 will always be printed, unless the logger is disabled. Prefer to use        a minimum level of 1.\nwidth Width of the column. Data is left-aligned to this width.\nccrayon A ConditionalCrayon for conditional formatting.\n\nModified an existing entry\n\nThis method can also modify an existing entry, if name is already a field int the logger. The type can be omitted in this case. Simply specify any of the keyword arguments  with the new setting.\n\n\n\n\n\n","category":"function"},{"location":"api/#SolverLogging.set_default_format","page":"API","title":"SolverLogging.set_default_format","text":"set_default_format(logger, type, fmt)\n\nSet the default format for entries type type is a sub-type of type. For example:\n\nset_default_format(logger, AbstractFloat, \"%0.2d\")\n\nWill print all floating point fields with 2 decimal places. The most format for the  type closest to the default is always chosen, such that if we specified \n\nset_default_format(logger, Float64, \"%0.1d\")\n\nThis would override the previous behavior for Float64s.\n\n\n\n\n\n","category":"function"},{"location":"api/#Logging","page":"API","title":"Logging","text":"","category":"section"},{"location":"api/","page":"API","title":"API","text":"@log\n_log!","category":"page"},{"location":"api/#SolverLogging.@log","page":"API","title":"SolverLogging.@log","text":"@log [logger] args...\n\nLogs the data with logger, which is the default logger if not provided. Can be any of the following forms:\n\n@log \"name\" 1.0    # literal value\n@log \"name\" 2a     # an expression\n@log \"name\" name   # a variable\n@log name          # shortcut for previous\n\nIf the specified entry is active at the current verbosity level, \n\n\n\n\n\n","category":"macro"},{"location":"api/#SolverLogging._log!","page":"API","title":"SolverLogging._log!","text":"_log!(logger, name, val)\n\nInternal method for logging a value with the logger. Users should prefer to use the @log macro. If name is a registered field, val will be stored in the logger.\n\nInternally, this method converts val to a string using the format specifications and calculates the color using the ConditionalCrayon for the entry.\n\n\n\n\n\n","category":"function"},{"location":"api/#Conditional-Formatting","page":"API","title":"Conditional Formatting","text":"","category":"section"},{"location":"api/","page":"API","title":"API","text":"ConditionalCrayon","category":"page"},{"location":"api/#SolverLogging.ConditionalCrayon","page":"API","title":"SolverLogging.ConditionalCrayon","text":"ConditionalCrayon\n\nSets conditional formatting for printing to the terminal. Each ConditionalCrayon  specifies a function bad(x) that returns true if the argument x is not acceptable, printing with color cbad, and a function good(x) that returns true if x is  acceptable, printing with color cgood. If neither are true then cdefault is the  color. The bad function will be checked before good, so takes precedence if both  happen to return true. This is not checked.\n\nAll colors must be specified as a Crayon type from Crayons.jl\n\nConstructors\n\nUsage will generally be through the following constructor:\n\nConditionalCrayon(badfun::Function, goodfun::Function; [goodcolor, badcolor, defaultcolor])\n\nThe colors default to green for good, red for bad, and default color (Crayon(reset=true))  for the default.\n\nFor convenience when working with ranges, the following constructor is also provided:\n\nConditionalCrayon(lo, hi; [reverse, goodcolor, badcolor, defaultcolor])\n\nWhich will be good if the value is less than lo and bad if it's higher than hi. This is reversed if reverse=true.\n\nA default constructor\n\nConditionalCrayon()\n\nIs also provided, which always returns the default color.\n\nUsage\n\nThe ConditionalCrayon is a functor object that accepts a single argument of any type, and returns the Crayon according to the output of the good and bad functions on that input. It's the user's responsibility to make sure the input type is appropriate for the  functions (since these are all user-specified).\n\n\n\n\n\n","category":"type"},{"location":"examples/#examples_section","page":"Examples","title":"Examples","text":"","category":"section"},{"location":"examples/","page":"Examples","title":"Examples","text":"CurrentModule = SolverLogging","category":"page"},{"location":"examples/#Setting-up-a-Logger","page":"Examples","title":"Setting up a Logger","text":"","category":"section"},{"location":"examples/","page":"Examples","title":"Examples","text":"The Quickstart used the default logger provided by this package. It's  usually a better idea to have your own local logger you can use, to avoid  possible conflicts. ","category":"page"},{"location":"examples/","page":"Examples","title":"Examples","text":"tip: Tip\nYou can extract the default logger by accessing it directly at SolverLogger.DEFAULT_LOGGER","category":"page"},{"location":"examples/","page":"Examples","title":"Examples","text":"using SolverLogging\nlogger = SolverLogging.Logger()\nsetentry(logger, \"iter\", Int, width=5)\nsetentry(logger, \"cost\")\nsetentry(logger, \"dJ\", level=2)\nsetentry(logger, \"info\", String, width=25)","category":"page"},{"location":"examples/","page":"Examples","title":"Examples","text":"We can change a few things about the behavior of our logger by accessing the  logger options. Here we change the header print frequency to print every 5  iterations instead of the default 10, eliminate the line under the header, and set the header to print in bold yellow:","category":"page"},{"location":"examples/","page":"Examples","title":"Examples","text":"using Crayons\nlogger.opts.freq = 5\nlogger.opts.linechar = '\\0'\nlogger.opts.headerstyle = crayon\"bold yellow\";","category":"page"},{"location":"examples/","page":"Examples","title":"Examples","text":"If we set the verbosity to 1 and print, we'll see that it doesn't print the dJ field:","category":"page"},{"location":"examples/","page":"Examples","title":"Examples","text":"setlevel!(logger, 1)\nJprev = 100\nfor iter = 1:3\n    global Jprev\n    J = 100/iter\n    @log logger iter\n    @log logger \"cost\" J\n    @log logger \"dJ\" Jprev - J  # note this is disregarded\n    Jprev = J\n    if iter == 5\n        @log logger \"info\" \"Last Iteration\"\n    end\n    printlog(logger)\nend","category":"page"},{"location":"examples/","page":"Examples","title":"Examples","text":"If we change the verbosity to 2, we now see dJ printed out:","category":"page"},{"location":"examples/","page":"Examples","title":"Examples","text":"setlevel!(logger, 2)  # note the change to 2\nJprev = 100\nfor iter = 1:5\n    global Jprev\n    J = 100/iter\n    @log logger iter\n    @log logger \"cost\" J\n    @log logger \"dJ\" Jprev - J\n    Jprev = J\n    if iter == 5\n        @log logger \"info\" \"Last Iteration\"\n    end\n    printlog(logger)\nend","category":"page"},{"location":"examples/","page":"Examples","title":"Examples","text":"Note how the new output doesn't start with a header, since it's continuing the  count from before. We can change this by resetting the count with resetcount!:","category":"page"},{"location":"examples/","page":"Examples","title":"Examples","text":"setlevel!(logger, 1)               # note the change back to 1\nSolverLogging.resetcount!(logger)  # this resets the print count\nJprev = 100\nfor iter = 1:5\n    global Jprev\n    J = 100/iter\n    @log logger iter\n    @log logger \"cost\" J\n    @log logger \"dJ\" Jprev - J\n    Jprev = J\n    if iter == 5\n        @log logger \"info\" \"Last Iteration\"\n    end\n    printlog(logger)\nend","category":"page"},{"location":"examples/","page":"Examples","title":"Examples","text":"So that, as you can see, we now get a nice output with the header at the top. By  changing the verbosity level back to 1, you see that it got rid of the dJ column  again.","category":"page"},{"location":"examples/#Conditional-Formatting","page":"Examples","title":"Conditional Formatting","text":"","category":"section"},{"location":"examples/","page":"Examples","title":"Examples","text":"In this example we cover how to use the conditional formatting. Lets say we have a field tol that we want below 1e-6. We also have another field control that  we want to be \"good\" if it's absolute value is less than 1, and \"bad\" if it's  greater than 10.","category":"page"},{"location":"examples/","page":"Examples","title":"Examples","text":"We create 2 ConditionalCrayon types to encode this behavior. Our first one can be covered using the constructor that takes a lo and hi value:","category":"page"},{"location":"examples/","page":"Examples","title":"Examples","text":"using SolverLogging\nccrayon_tol = ConditionalCrayon(1e-6,Inf, reverse=false)\nnothing # hide","category":"page"},{"location":"examples/","page":"Examples","title":"Examples","text":"Which by default will consider any values less than lo good and any values greater than hi bad. We can reverse this with the optional reverse keyword.","category":"page"},{"location":"examples/","page":"Examples","title":"Examples","text":"For our control formatting, let's say we want it to print orange if it's absolute  value is in between 1 and 10 and cyan if it's less than 1:","category":"page"},{"location":"examples/","page":"Examples","title":"Examples","text":"using Crayons\ngoodctrl = x->abs(x) < 1 \nbadctrl = x->abs(x) > 10\nlowcolor = crayon\"blue\"\ndefcolor = crayon\"208\"  # the ANSI color for a dark orange. \nccrayon_control = ConditionalCrayon(badctrl, goodctrl, \n    defaultcolor=defcolor, goodcolor=crayon\"cyan\")\nnothing # hide","category":"page"},{"location":"examples/","page":"Examples","title":"Examples","text":"tip: Tip\nUse Crayons.test_256_colors() to generate a sample of all the ANSI color codes.","category":"page"},{"location":"examples/","page":"Examples","title":"Examples","text":"We can now specify these when we set up our fields:","category":"page"},{"location":"examples/","page":"Examples","title":"Examples","text":"logger = SolverLogging.Logger()\nsetentry(logger, \"iter\", Int, width=5)\nsetentry(logger, \"tol\", Float64, ccrayon=ccrayon_tol)\nsetentry(logger, \"ctrl\", Float64, fmt=\"%.1f\", ccrayon=ccrayon_control)","category":"page"},{"location":"examples/","page":"Examples","title":"Examples","text":"We should see the desired behavior when we print out some test values:","category":"page"},{"location":"examples/","page":"Examples","title":"Examples","text":"for iter = 1:10\n    tol = exp10(-iter)\n    ctrl = 0.1*(iter-1)*iter^2\n    @log logger iter\n    @log logger tol\n    @log logger ctrl\n    printlog(logger)\nend","category":"page"},{"location":"examples/#Saving-to-a-File","page":"Examples","title":"Saving to a File","text":"","category":"section"},{"location":"examples/","page":"Examples","title":"Examples","text":"Instead of writing to stdout, we can write a to a file. This interface is exactly the same, but we pass a filename or an IOStream to the logger when we create it:","category":"page"},{"location":"examples/","page":"Examples","title":"Examples","text":"using SolverLogging\nfilename = \"log.out\"\nlogger = SolverLogging.Logger(filename)","category":"page"},{"location":"examples/","page":"Examples","title":"Examples","text":"Note that this will automatically open the file with read privileges, overwritting  any contents in the file. The stream is flushed after every write so it should  populate the contents of the file in real time.","category":"page"},{"location":"#SolverLogging.jl","page":"Introduction","title":"SolverLogging.jl","text":"","category":"section"},{"location":"#Overview","page":"Introduction","title":"Overview","text":"","category":"section"},{"location":"","page":"Introduction","title":"Introduction","text":"This package provides a logger that is designed for use in iterative solvers. The logger presents data in a tabulated format, with each line representing  the data from an iteration of the solver. The key features of this package are:","category":"page"},{"location":"","page":"Introduction","title":"Introduction","text":"The ability to handle different verbosity levels. Assumes each verbosity level  contains all information from previous levels. Allows the user to scale the  information based on current needs.\nPrecise control over output formatting. The location, column width, and entry formatting for each field can be controlled.\nColor printing to the terminal thanks to Crayons.jl\nConditional formatting that allows values to be automatically formatted  based on a the current value.","category":"page"},{"location":"#Quickstart","page":"Introduction","title":"Quickstart","text":"","category":"section"},{"location":"","page":"Introduction","title":"Introduction","text":"To use the default logger provided by the package, start by specifying the fields you want to log:","category":"page"},{"location":"","page":"Introduction","title":"Introduction","text":"using SolverLogging\nSolverLogging.resetlogger!()  # good idea to always reset the global logger\nsetentry(\"iter\", Int, width=5)\nsetentry(\"cost\")\nsetentry(\"info\", String, width=25) \nsetentry(\"α\", fmt=\"%6.4f\")  # sets the numeric formatting\nsetentry(\"ΔJ\", index=-2)    # sets it to penultimate column\nsetentry(\"tol\", level=2)    # sets it to verbosity level 2  (prints less often)","category":"page"},{"location":"","page":"Introduction","title":"Introduction","text":"After specifying the data we want to log, we log the data using the @log macro:","category":"page"},{"location":"","page":"Introduction","title":"Introduction","text":"@log \"iter\" 1\n@log \"cost\" 10.2","category":"page"},{"location":"","page":"Introduction","title":"Introduction","text":"Note this macro allows expressions:","category":"page"},{"location":"","page":"Introduction","title":"Introduction","text":"dJ = 1e-3\nstr = \"Some Error Code: \"\n@log \"ΔJ\" dJ\n@log \"info\" str * string(10)","category":"page"},{"location":"","page":"Introduction","title":"Introduction","text":"As a convenient shortcut, we if the local variable name matches the name of the field we can just pass the local variable and the name will be automatically extracted:","category":"page"},{"location":"","page":"Introduction","title":"Introduction","text":"iter = 2\n@log iter ","category":"page"},{"location":"","page":"Introduction","title":"Introduction","text":"To print the output use printlog:","category":"page"},{"location":"","page":"Introduction","title":"Introduction","text":"iter = 2\n@log iter ","category":"page"},{"location":"","page":"Introduction","title":"Introduction","text":"which will automatically handle printing the header lines. Here we call it in a loop, updating the iteration field each time:","category":"page"},{"location":"","page":"Introduction","title":"Introduction","text":"for iter = 1:15\n    @log iter\n    printlog()\nend","category":"page"},{"location":"#API","page":"Introduction","title":"API","text":"","category":"section"},{"location":"","page":"Introduction","title":"Introduction","text":"See the API page for details on how to use the logger in your application.","category":"page"},{"location":"#Examples","page":"Introduction","title":"Examples","text":"","category":"section"},{"location":"","page":"Introduction","title":"Introduction","text":"See the Examples page for a few example to help you get started.","category":"page"}]
}
