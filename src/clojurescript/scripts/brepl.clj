(require
  '[cljs.build.api :as b]
  '[cljs.repl :as repl]
  '[cljs.repl.browser :as browser])

(b/build "src"
  {:main 'svgdraw.core
   :output-to "out/svgdraw.js"
   :output-dir "out"
   :verbose true})

(repl/repl (browser/repl-env)
  :watch "src"
  :output-dir "out")
