; extends
; vim: set tabstop=2 shiftwidth=2 expandtab:

; START: yaml injections for embedded languages
; affects strings annotated with a comment like "# lang:python"

((comment) @injection.language
  . (block_node (block_scalar) @injection.content)
  (#lua-match? @injection.language "lang:%w")
  (#gsub! @injection.language "^%s*#!?%s*lang:(%w+)" "%1")
  (#offset-first-line! @injection.content)
)

((block_scalar (comment) @injection.language) @injection.content
  (#gsub! @injection.language "^%s*#!?%s*lang:(%w+)" "%1")
  (#offset-first-line! @injection.content)
  (#set! injection.include-children)
)

((comment) @injection.language
  . (flow_node (plain_scalar) @injection.content)
  (#gsub! @injection.language "^%s*#!?%s*lang:(%w+)" "%1")
  (#set! injection.include-children))

((comment) @injection.language
  . (flow_node [(single_quote_scalar) (double_quote_scalar)] @injection.content)
  (#gsub! @injection.language "^%s*#!?%s*lang:(%w+)" "%1")
  (#offset! @injection.content 0 1 0 -1)  ; remove quotes
)

((comment) @injection.language
  . (block_node
      (block_mapping
        (block_mapping_pair
          value: (flow_node (plain_scalar) @injection.content))))
  (#gsub! @injection.language "^%s*#!?%s*lang:(%w+)" "%1")
  (#set! injection.include-children))

((comment) @injection.language
  . (block_node
      (block_mapping
        (block_mapping_pair
          value: (flow_node [(single_quote_scalar) (double_quote_scalar)] @injection.content))))
  (#gsub! @injection.language "^%s*#!?%s*lang:(%w+)" "%1")
  (#offset! @injection.content 0 1 0 -1))

((comment) @injection.language
  . (block_node
      (block_mapping
        (block_mapping_pair
          value: (block_node (block_scalar) @injection.content))))
  (#gsub! @injection.language "^%s*#!?%s*lang:(%w+)" "%1")
  (#offset-first-line! @injection.content))

; END: yaml injections for embedded languages
