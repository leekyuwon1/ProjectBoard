<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@page import="java.net.URLEncoder"%>
<%@page import="java.net.URLDecoder"%>
<%@page import="lkw.com.obp.board.utils.MyUtil"%>
<%@page import="java.util.List"%>
<%@page import="lkw.com.obp.board.BoardDTO"%>
<%@page import="lkw.com.obp.board.BoardDAO"%>
<%@page import="lkw.com.obp.board.utils.DBConn"%>
<%@page import="java.sql.Connection"%>
<%@ page contentType="text/html; charset=UTF-8"%>
<%
    request.setCharacterEncoding("UTF-8");
    String cp = request.getContextPath();

    //BoardDAO dao = new BoardDAO(DBConn.getConnection());
    Connection conn = DBConn.getConnection();
    BoardDAO dao = new BoardDAO(conn);


    MyUtil myUtil = new MyUtil();

    //get방식으로 넘어온 페이지 번호(myUtil...)
    String pageNum = request.getParameter("pageNum"); //겟파라미터로 받는다

    //첫 시작 시 현재페이지 : 1
    int currentPage = 1;

    //넘어온 페이지번호가 존재할 경우 현재페이지에 값 넣기
    if (pageNum != null && pageNum.matches("\\d+")) {
        currentPage = Integer.parseInt(pageNum);
    }

    //검색키, 검색값
    String searchKey = request.getParameter("searchKey");
    String searchValue = request.getParameter("searchValue");

    //검색값이 있을 경우
    if(searchValue != null) {

        if(request.getMethod().equalsIgnoreCase("GET")) {
            searchValue = URLDecoder.decode(searchValue, "UTF-8");
        }
        //검색값이 없을 경우
    }else {
        searchKey = "subject";
        searchValue = "";
    }


    //전체 데이터 갯수 구하기
    int dataCount = dao.getDataCount(searchKey,searchValue);

    //하나의 페이지에 표시할 데이터 갯수
    int numPerPage = 3;

    //전체 페이지 갯수
    int totalPage = myUtil.getPageCount(numPerPage, dataCount);

    //데이터를 삭제해서 페이지가 줄었을 때
    if(currentPage > totalPage) {
        currentPage = totalPage;
    }

    //DB에서 가져올 데이터의 시작과 끝
    int start = (currentPage-1) * numPerPage+1;
    int end = currentPage * numPerPage;

    //DB에서 해당 페이지를 가져옴
    List<BoardDTO> lists = dao.getLists(start, end,searchKey,searchValue);


    //검색 - 검색기능을 사용할 경우 get방식의 주소에 추가로 적용.
    String param = "";
    //null이 아니면 검색을 한 것이다.
    if(!searchValue.equals("")) {

        //이때 주소를 만들어준다
        param = "?searchKey=" + searchKey;
        param+= "&searchValue=" + URLEncoder.encode(searchValue, "UTF-8");

    }

    //페이징 처리
    String listUrl = "list.jsp" + param; //param 검색을 안했으면 null이 들어간다.됬다면 주소


    String pageIndexList =
            myUtil.pageIndexList(currentPage, totalPage, listUrl);


    //글보기 주소

    String articleUrl = cp + "/article.jsp";

    if(param.equals("")) { //검색을 안했을 때
        articleUrl += "?pageNum=" + currentPage;
    } else { //검색을 했을 때
        articleUrl += param + "&pageNum=" + currentPage;
    }


    DBConn.close();


%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <title>게 시 판</title>

    <link rel="stylesheet" type="text/css" href="<%=cp%>/css/style.css"/>
    <link rel="stylesheet" type="text/css" href="<%=cp%>/css/list.css"/>

    <script type="text/javascript">

        function sendIt() {

            var f = document.searchForm;

            //검색 버튼을 누를경우 리스트페이지로 이동
            f.action = "<%=cp%>/list.jsp";
            f.submit();
        }

    </script>


</head>
<body>

<div id="bbsList">

    <div id="bbsList_title">
        게 시 판
    </div>
    <div id="bbsList_header">
        <div id="leftHeader">
            <form action="" method="post" name="searchForm">
                <select name="searchKey" class="selectField">
                    <option value="subject">제목</option>
                    <option value="name">작성자</option>
                    <option value="content">내용</option>
                </select>
                <input type="text" name="searchValue" class="textField"/>
                <input type="button" value=" 검 색 " class="btn2" onclick="sendIt();"/>
            </form>
        </div>
        <div id="rightHeader">
            <input type="button" value=" 글올리기 " class="btn2"
                   onclick="javascript:location.href='created.jsp';"/>
        </div>
    </div>
    <div id="bbsList_list">
        <div id="title">
            <dl>
                <dt class="num">번호</dt>
                <dt class="subject">제목</dt>
                <dt class="name">작성자</dt>
                <dt class="created">작성일</dt>
                <dt class="hitCount">조회수</dt>
            </dl>
        </div>

        <div id="lists">
            <%for(BoardDTO dto : lists){ %>
            <dl>
                <dd class="num"><%=dto.getNum() %></dd>
                <dd class="subject">
                    <a href="<%=articleUrl %>&num=<%=dto.getNum()%>">
                        <%=dto.getSubject() %></a>
                    <!-- currentPage는 현재 내가보고있는 페이지 -->
                </dd>
                <dd class="name"><%=dto.getName() %></dd>
                <dd class="created"><%=dto.getCreated() %></dd>
                <dd class="hitCount"><%=dto.getHitCount() %></dd>
            </dl>
            <%} %>
        </div>
        <div id="footer">
            <%=pageIndexList %>
        </div>

    </div>

</div>

</body>
</html>