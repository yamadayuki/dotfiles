# =============================================================================
# Syntax Highlighting & Color Theme (ported from conf.d/shell.fish)
# =============================================================================

export def get_theme [] {
    {
        recognizing_syntax: true
        shape_and: "cyan_bold"
        shape_binary: "purple_bold"
        shape_block: "blue_bold"
        shape_bool: "light_cyan"
        shape_closure: "green_bold"
        shape_custom: "magenta"
        shape_datetime: "cyan_bold"
        shape_directory: "cyan_bold"
        shape_external: "blue_bold"
        shape_externalarg: "green"
        shape_filepath: "cyan"
        shape_flag: "cyan_bold"
        shape_float: "purple_bold"
        shape_garbage: { fg: "#ffffff" bg: "#ff0000" attr: b }
        shape_globpattern: "cyan_bold"
        shape_int: "purple_bold"
        shape_internalcall: "blue_bold"
        shape_keyword: "cyan_bold"
        shape_list: "cyan_bold"
        shape_literal: "blue"
        shape_match_pattern: "green"
        shape_matching_brackets: { attr: u }
        shape_nothing: "light_cyan"
        shape_operator: "cyan"
        shape_or: "cyan_bold"
        shape_pipe: "cyan_bold"
        shape_range: "yellow_bold"
        shape_record: "cyan_bold"
        shape_redirection: "cyan_bold"
        shape_signature: "green_bold"
        shape_string: "yellow"
        shape_string_interpolation: "cyan_bold"
        shape_table: "blue_bold"
        shape_variable: "green"
        shape_vardecl: "green"
        shape_comment: "dark_gray"
        shape_error: "red_bold"
        empty: "blue"
        header: "green_bold"
        hints: "dark_gray"
        leading_trailing_space_bg: { attr: n }
        row_index: "green_bold"
        search_result: { fg: "white" bg: "dark_gray" }
        separator: "white"
    }
}
