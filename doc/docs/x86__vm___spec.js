GNATdoc.Documentation = {
  "label": "X86.Vm",
  "qualifier": "",
  "summary": [
  ],
  "description": [
  ],
  "entities": [
    {
      "entities": [
        {
          "label": "Page_Size",
          "qualifier": "",
          "line": 8,
          "column": 9,
          "src": "srcs/x86-vm.ads.html",
          "summary": [
          ],
          "description": [
            {
              "kind": "code",
              "children": [
                {
                  "kind": "line",
                  "number": 8,
                  "children": [
                    {
                      "kind": "span",
                      "cssClass": "text",
                      "text": "   "
                    },
                    {
                      "kind": "span",
                      "cssClass": "keyword",
                      "text": "type"
                    },
                    {
                      "kind": "span",
                      "cssClass": "text",
                      "text": " "
                    },
                    {
                      "kind": "span",
                      "cssClass": "identifier",
                      "text": "Page_Size",
                      "href": "docs/x86__vm___spec.html#L8C9"
                    },
                    {
                      "kind": "span",
                      "cssClass": "text",
                      "text": " "
                    },
                    {
                      "kind": "span",
                      "cssClass": "keyword",
                      "text": "is"
                    },
                    {
                      "kind": "span",
                      "cssClass": "text",
                      "text": " "
                    },
                    {
                      "kind": "span",
                      "cssClass": "identifier",
                      "text": "("
                    },
                    {
                      "kind": "span",
                      "cssClass": "identifier",
                      "text": "Page_4K",
                      "href": "docs/x86__vm___spec.html#L8C23"
                    },
                    {
                      "kind": "span",
                      "cssClass": "identifier",
                      "text": ","
                    },
                    {
                      "kind": "span",
                      "cssClass": "text",
                      "text": " "
                    },
                    {
                      "kind": "span",
                      "cssClass": "identifier",
                      "text": "Page_2M",
                      "href": "docs/x86__vm___spec.html#L8C32"
                    },
                    {
                      "kind": "span",
                      "cssClass": "identifier",
                      "text": ")"
                    },
                    {
                      "kind": "span",
                      "cssClass": "identifier",
                      "text": ";",
                      "href": "docs/x86__vm___spec.html#L8C9"
                    }
                  ]
                }
              ]
            },
            {
              "kind": "paragraph",
              "children": [
                {
                  "kind": "span",
                  "text": "public constants & types\n"
                }
              ]
            }
          ],
          "literals": [
            {
              "label": "Page_4K",
              "line": 8,
              "column": 23,
              "description": [
              ]
            },
            {
              "label": "Page_2M",
              "line": 8,
              "column": 32,
              "description": [
              ]
            }
          ]
        }
      ],
      "label": "Simple types"
    },
    {
      "entities": [
        {
          "label": "Dump_Pages",
          "qualifier": "",
          "line": 12,
          "column": 14,
          "src": "srcs/x86-vm.ads.html",
          "summary": [
          ],
          "description": [
            {
              "kind": "code",
              "children": [
                {
                  "kind": "line",
                  "number": 12,
                  "children": [
                    {
                      "kind": "span",
                      "cssClass": "text",
                      "text": "   "
                    },
                    {
                      "kind": "span",
                      "cssClass": "keyword",
                      "text": "procedure"
                    },
                    {
                      "kind": "span",
                      "cssClass": "text",
                      "text": " "
                    },
                    {
                      "kind": "span",
                      "cssClass": "identifier",
                      "text": "Dump_Pages",
                      "href": "docs/x86__vm___spec.html#L12C14"
                    },
                    {
                      "kind": "span",
                      "cssClass": "identifier",
                      "text": ";"
                    }
                  ]
                }
              ]
            },
            {
              "kind": "paragraph",
              "children": [
                {
                  "kind": "span",
                  "text": "TODO: generalise, uses %cr3 now (take PML4 base parameter for other roots?)\n"
                }
              ]
            }
          ]
        },
        {
          "label": "Map_Page",
          "qualifier": "",
          "line": 16,
          "column": 13,
          "src": "srcs/x86-vm.ads.html",
          "summary": [
          ],
          "description": [
            {
              "kind": "code",
              "children": [
                {
                  "kind": "line",
                  "number": 16,
                  "children": [
                    {
                      "kind": "span",
                      "cssClass": "text",
                      "text": "   "
                    },
                    {
                      "kind": "span",
                      "cssClass": "keyword",
                      "text": "function"
                    },
                    {
                      "kind": "span",
                      "cssClass": "text",
                      "text": " "
                    },
                    {
                      "kind": "span",
                      "cssClass": "identifier",
                      "text": "Map_Page",
                      "href": "docs/x86__vm___spec.html#L16C13"
                    },
                    {
                      "kind": "span",
                      "cssClass": "identifier",
                      "text": "("
                    },
                    {
                      "kind": "span",
                      "cssClass": "text",
                      "text": "   "
                    },
                    {
                      "kind": "span",
                      "cssClass": "identifier",
                      "text": "PML4",
                      "href": "docs/x86__vm___spec.html#L16C25"
                    },
                    {
                      "kind": "span",
                      "cssClass": "identifier",
                      "text": ":"
                    },
                    {
                      "kind": "span",
                      "cssClass": "text",
                      "text": "    "
                    },
                    {
                      "kind": "span",
                      "cssClass": "identifier",
                      "text": "Physical_Address",
                      "href": "docs/common___spec.html#L6C10"
                    },
                    {
                      "kind": "span",
                      "cssClass": "identifier",
                      "text": ";"
                    },
                    {
                      "kind": "span",
                      "cssClass": "text",
                      "text": " "
                    }
                  ]
                },
                {
                  "kind": "line",
                  "number": 17,
                  "children": [
                    {
                      "kind": "span",
                      "cssClass": "text",
                      "text": "                        "
                    },
                    {
                      "kind": "span",
                      "cssClass": "identifier",
                      "text": "VMA",
                      "href": "docs/x86__vm___spec.html#L17C25"
                    },
                    {
                      "kind": "span",
                      "cssClass": "identifier",
                      "text": ":"
                    },
                    {
                      "kind": "span",
                      "cssClass": "text",
                      "text": "     "
                    },
                    {
                      "kind": "span",
                      "cssClass": "identifier",
                      "text": "Virtual_Address",
                      "href": "docs/common___spec.html#L7C10"
                    },
                    {
                      "kind": "span",
                      "cssClass": "identifier",
                      "text": ";"
                    },
                    {
                      "kind": "span",
                      "cssClass": "text",
                      "text": " "
                    }
                  ]
                },
                {
                  "kind": "line",
                  "number": 18,
                  "children": [
                    {
                      "kind": "span",
                      "cssClass": "text",
                      "text": "                        "
                    },
                    {
                      "kind": "span",
                      "cssClass": "identifier",
                      "text": "PA",
                      "href": "docs/x86__vm___spec.html#L18C25"
                    },
                    {
                      "kind": "span",
                      "cssClass": "identifier",
                      "text": ":"
                    },
                    {
                      "kind": "span",
                      "cssClass": "text",
                      "text": "      "
                    },
                    {
                      "kind": "span",
                      "cssClass": "identifier",
                      "text": "Physical_Address",
                      "href": "docs/common___spec.html#L6C10"
                    },
                    {
                      "kind": "span",
                      "cssClass": "identifier",
                      "text": ";"
                    }
                  ]
                },
                {
                  "kind": "line",
                  "number": 19,
                  "children": [
                    {
                      "kind": "span",
                      "cssClass": "text",
                      "text": "                        "
                    },
                    {
                      "kind": "span",
                      "cssClass": "identifier",
                      "text": "Size",
                      "href": "docs/x86__vm___spec.html#L19C25"
                    },
                    {
                      "kind": "span",
                      "cssClass": "identifier",
                      "text": ":"
                    },
                    {
                      "kind": "span",
                      "cssClass": "text",
                      "text": "    "
                    },
                    {
                      "kind": "span",
                      "cssClass": "identifier",
                      "text": "Page_Size",
                      "href": "docs/x86__vm___spec.html#L8C9"
                    },
                    {
                      "kind": "span",
                      "cssClass": "identifier",
                      "text": ")"
                    },
                    {
                      "kind": "span",
                      "cssClass": "text",
                      "text": " "
                    }
                  ]
                },
                {
                  "kind": "line",
                  "number": 20,
                  "children": [
                    {
                      "kind": "span",
                      "cssClass": "text",
                      "text": "                        "
                    },
                    {
                      "kind": "span",
                      "cssClass": "keyword",
                      "text": "return"
                    },
                    {
                      "kind": "span",
                      "cssClass": "text",
                      "text": " "
                    },
                    {
                      "kind": "span",
                      "cssClass": "identifier",
                      "text": "Boolean"
                    },
                    {
                      "kind": "span",
                      "cssClass": "identifier",
                      "text": ";"
                    }
                  ]
                }
              ]
            },
            {
              "kind": "paragraph",
              "children": [
                {
                  "kind": "span",
                  "text": "TODO: extend the setting of flags\n"
                },
                {
                  "kind": "span",
                  "text": "TODO: separate Virtual_Address subtype?\n"
                }
              ]
            }
          ],
          "parameters": [
            {
              "label": "PML4",
              "line": 16,
              "column": 25,
              "type": {
                "label": "Common.Physical_Address",
                "docHref": "docs/common___spec.html#L6C10"
              },
              "description": [
              ]
            },
            {
              "label": "VMA",
              "line": 17,
              "column": 25,
              "type": {
                "label": "Common.Virtual_Address",
                "docHref": "docs/common___spec.html#L7C10"
              },
              "description": [
              ]
            },
            {
              "label": "PA",
              "line": 18,
              "column": 25,
              "type": {
                "label": "Common.Physical_Address",
                "docHref": "docs/common___spec.html#L6C10"
              },
              "description": [
              ]
            },
            {
              "label": "Size",
              "line": 19,
              "column": 25,
              "type": {
                "label": "X86.Vm.Page_Size",
                "docHref": "docs/x86__vm___spec.html#L8C9"
              },
              "description": [
              ]
            }
          ]
        }
      ],
      "label": "Subprograms"
    }
  ]
};