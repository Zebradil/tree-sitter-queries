;extends

; Marker before plain scalar
;
; key: # lang:<injection.language>
;   <injection.content>
;
((comment) @injection.language
  . (flow_node (plain_scalar) @injection.content)
  (#gsub! @injection.language "^%s*#!?%s*lang:(%w+)" "%1")
  (#set! injection.include-children))

; Marker before quoted scalar (single or double quotes)
;
; key: # lang:<injection.language>
;   "<injection.content>"
;
((comment) @injection.language
  . (flow_node [(single_quote_scalar) (double_quote_scalar)] @injection.content)
  (#gsub! @injection.language "^%s*#!?%s*lang:(%w+)" "%1")
  (#offset! @injection.content 0 1 0 -1)  ; remove quotes
)

; Marker before block scalar (|, |-, >, >-)
;
; key: # lang:<injection.language>
;   |
;   <injection.content>
;
((comment) @injection.language
  . (block_node (block_scalar) @injection.content)
  (#lua-match? @injection.language "lang:%w")
  (#gsub! @injection.language "^%s*#!?%s*lang:(%w+)" "%1")
  (#offset-first-line! @injection.content)
)

; Marker inside block scalar (|, |-, >, >-)
;
; key: | # lang:<injection.language>
;   <injection.content>
;
((block_scalar (comment) @injection.language) @injection.content
  (#gsub! @injection.language "^%s*#!?%s*lang:(%w+)" "%1")
  (#offset-first-line! @injection.content)
  (#set! injection.include-children)
)

; Marker before block mapping pairs with plain scalars
;
; key: # lang:<injection.language>
;   subkeyN: <injection.content>
;
((comment) @injection.language
  . (block_node
      (block_mapping
        (block_mapping_pair
          value: (flow_node (plain_scalar) @injection.content))))
  (#gsub! @injection.language "^%s*#!?%s*lang:(%w+)" "%1")
  (#set! injection.include-children))

; Marker before block mapping pairs with quoted scalars (single or double quotes)
;
; key: # lang:<injection.language>
;   subkeyN: "<injection.content>"
;
((comment) @injection.language
  . (block_node
      (block_mapping
        (block_mapping_pair
          value: (flow_node [(single_quote_scalar) (double_quote_scalar)] @injection.content))))
  (#gsub! @injection.language "^%s*#!?%s*lang:(%w+)" "%1")
  (#offset! @injection.content 0 1 0 -1))

; Marker before block mapping pairs with block scalars (|, |-, >, >-)
;
; key: # lang:<injection.language>
;   subkeyN: |
;     <injection.content>
;
((comment) @injection.language
  . (block_node
      (block_mapping
        (block_mapping_pair
          value: (block_node (block_scalar) @injection.content))))
  (#gsub! @injection.language "^%s*#!?%s*lang:(%w+)" "%1")
  (#offset-first-line! @injection.content))

; Marker before block sequence items with plain scalars
;
; key: # lang:<injection.language>
;   - <injection.content>
;
((comment) @injection.language
  . (block_node
      (block_sequence
        (block_sequence_item
          (flow_node (plain_scalar) @injection.content))))
  (#gsub! @injection.language "^%s*#!?%s*lang:(%w+)" "%1")
  (#set! injection.include-children))

; Marker before block sequence items with quoted scalars (single or double quotes)
;
; key: # lang:<injection.language>
;   - "<injection.content>"
;
((comment) @injection.language
  . (block_node
      (block_sequence
        (block_sequence_item
          (flow_node [(single_quote_scalar) (double_quote_scalar)] @injection.content))))
  (#gsub! @injection.language "^%s*#!?%s*lang:(%w+)" "%1")
  (#offset! @injection.content 0 1 0 -1))

; Marker before block sequence items with block scalars (|, |-, >, >-)
;
; key: # lang:<injection.language>
;   - |
;     <injection.content>
;
((comment) @injection.language
  . (block_node
      (block_sequence
        (block_sequence_item
          (block_node (block_scalar) @injection.content))))
  (#gsub! @injection.language "^%s*#!?%s*lang:(%w+)" "%1")
  (#offset-first-line! @injection.content))
