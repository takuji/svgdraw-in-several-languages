(require '[cljs.build.api :as b])

(b/watch "src"
  {:main 'svgdraw.core
   :output-to "out/svgdraw.js"
   :output-dir "out"})
