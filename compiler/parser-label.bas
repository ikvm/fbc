'' label declarations
''
'' chng: sep/2004 written [v1ctor]


#include once "fb.bi"
#include once "fbint.bi"
#include once "parser.bi"
#include once "ast.bi"

'':::::
''Label           =   NUM_LIT
''                |   ID ':' .
''
function cLabel as integer
    dim as FBSYMBOL ptr l = NULL
    dim as FBSYMCHAIN ptr chain_ = any

    function = FALSE

    '' NUM_LIT
    select case as const lexGetClass( )
    case FB_TKCLASS_NUMLITERAL

    	if( fbLangOptIsSet( FB_LANG_OPT_NUMLABEL ) = FALSE ) then
	    	if( errReportNotAllowed( FB_LANG_OPT_NUMLABEL ) = FALSE ) then
				exit function
			else
				'' error recovery: skip stmt
				hSkipStmt( )
		    end if

		else
			l = symbAddLabel( lexGetText( ), _
							  FB_SYMBOPT_DECLARING or FB_SYMBOPT_CREATEALIAS )
			if( l = NULL ) then
				if( errReport( FB_ERRMSG_DUPDEFINITION ) = FALSE ) then
					exit function
				else
					'' error recovery: skip stmt
					hSkipStmt( )
				end if
			else
				lexSkipToken( )
			end if

			'' fake a ':'
			parser.stmt.cnt += 1
		end if

	'' ID (labels can't be quirk-keywords)
	case FB_TKCLASS_IDENTIFIER
		'' ':'
		if( lexGetLookAhead( 1 ) = FB_TK_STMTSEP ) then

			'' ambiguity: it could be a proc call followed by a ':' stmt separator..

			'' no need to call Identifier(), ':' wouldn't follow 'ns.symbol' ids
			chain_ = lexGetSymChain( )
			if( errGetLast( ) <> FB_ERRMSG_OK ) then
				exit function
			end if

			if( symbFindByClass( chain_, FB_SYMBCLASS_PROC ) <> NULL ) then
				exit function
			end if

			l = symbAddLabel( lexGetText( ), _
							  FB_SYMBOPT_DECLARING or FB_SYMBOPT_CREATEALIAS )
			if( l = NULL ) then
				if( errReport( FB_ERRMSG_DUPDEFINITION ) = FALSE ) then
					exit function
				end if
			end if

			lexSkipToken( )

			'' skip ':'
			lexSkipToken( )

		end if
    end select

    if( l <> NULL ) then
    	astAdd( astNewLABEL( l ) )

    	symbSetLastLabel( l )

    	function = TRUE
    end if

end function
