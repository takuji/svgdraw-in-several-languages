(ns svgdraw.core
  (:require [clojure.browser.repl :as repl]
            [cljsjs.d3]
            [clojure.core.match :refer-macros [match]]))

(defonce conn
  (repl/connect "http://localhost:9000/repl"))

(defn- new-drawing-state [line]
  {:type :drawing :line line})

(defn- get-mouse-position [{:keys [svg]}]
  (.mouse js/d3 svg))

(defn- add-line [{:keys [line-color line-width selection] :as draw}]
  (let [line (.line (.-svg js/d3))
        pen (.interpolate line "cardinal")
        points []
        selLine (.append selection "path")]
    (do
      (-> selLine
        (.attr "data-line-id" "1")
        (.attr "d" (pen (clj->js points))) 
        (.attr "fill" "transparent")
        (.attr "stroke" line-color))
      {:points points :color line-color :width line-width :pen pen :drawing selLine})))

(defn- update-line [{:keys [pen points drawing] :as line}]
  (.attr drawing "d" (pen (clj->js points))))

(defn- on-mouse-down [draw evt]
  (letfn [(start-drawing-state []
            (let [line (add-line @draw)
                  p (get-mouse-position @draw)]
              (swap! draw (fn [d] (assoc d :state (new-drawing-state line) :lines (conj (:lines d) line))))))]
    (match [(:state @draw)]
      [:waiting-state] (start-drawing-state)
      [{:type :drawing :line _}] nil)))

(defn- on-mouse-up [draw-ref evt]
  (.log js/console "up")
  (match [(:state @draw-ref)]
    [:waiting-state] nil
    [{:type :drawing :line line}] (do (update-line line)
                                            (swap! draw-ref (fn [d] (assoc d :state :waiting-state))))))

(defn- on-mouse-move [draw-ref evt]
  (.log js/console "move")
  (let [state (:state @draw-ref)]
    (match [state]
      [:waiting-state] nil
      [{:type :drawing :line line}]
        (let [p (get-mouse-position @draw-ref)
              line2 (assoc line :points (conj (:points line) p))]
          (update-line line2)
          (swap! draw-ref (fn [d] (assoc d :state (new-drawing-state line2))))))))

(defn- on-mouse-leave [draw-ref evt]
  (.log js/console "leave")
  (match [(:state @draw-ref)]
    [:waiting-state] nil
    [{:type :drawing :line line}] (do (update-line line)
                                            (swap! draw-ref (fn [d] (assoc d :state :waiting-state))))))

(defn- init-canvas [{:keys [selection width height background-color] :as draw}]
  (let [d-ref (atom draw)]
    (-> selection
      (.attr "width" (str width "px"))
      (.attr "height" (str height "px"))
      (.style "display" "inline-block")
      (.style "background-color" background-color)
      (.on "mousedown" (fn [e] (on-mouse-down d-ref e)))
      (.on "mouseup" (fn [e] (on-mouse-up d-ref e)))
      (.on "mousemove" (fn [e] (on-mouse-move d-ref e)))
      (.on "mouseleave" (fn [e] (on-mouse-leave d-ref e))))))

(defn create [{:keys [el width height] :as params}]
  (let [selection (.select js/d3 el)
        svg (get (get selection 0) 0)
        d {:width width
           :height height
           :el el
           :line-color "#000000"
           :line-width 1
           :background-color "#ffffff"
           :zoom 1.0
           :event-listeners []
           :lines []
           :selection selection
           :svg svg
           :state :waiting-state}]
    (.log js/console d)
    (init-canvas d)
    d))

(enable-console-print!)

(create {:el "#draw" :width 800 :height 600})