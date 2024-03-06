<?php
// require '../db_connect.php';
// header('Content-Type: application/json; charset=utf-8');

// // make input json
// $inputJSON = file_get_contents('php://input');
// $input = json_decode($inputJSON, TRUE);

// // if not put device_id die
// if($_SERVER['REQUEST_METHOD'] == 'POST' && array_key_exists('event_id', $input)){
//     $event_id = $input['event_id'];
    
//     $sql = "SELECT tbl_event_log.id, tbl_event_log.employee_id, tbl_employee.first_name, tbl_employee.last_name, tbl_employee.middle_name, tbl_event_log.event_id, tbl_event.event_name, tbl_event_log.time_stamp 
//     FROM tbl_event_log INNER JOIN tbl_employee ON tbl_employee.employee_id = tbl_event_log.employee_id INNER JOIN tbl_event ON tbl_event.event_id = tbl_event_log.event_id
//     WHERE tbl_event_log.event_id = :event_id ORDER BY tbl_event_log.time_stamp DESC;";

//     try {
//         $get_sql= $conn->prepare($sql);
//         $get_sql->bindParam(':event_id', $event_id, PDO::PARAM_STR);
//         $get_sql->execute();
//         $result_get_sql = $get_sql->fetchAll(PDO::FETCH_ASSOC);
//         echo json_encode($result_get_sql);
//     } catch (PDOException $e) {
//         echo json_encode(array('success'=>false,'message'=>$e->getMessage()));
//     } finally{
//         // Closing the connection.
//         $conn = null;
//     }
// }else{
//     echo json_encode(array('success'=>false,'message'=>'error input'));
//     die();
// }

require '../db_connect.php';
header('Content-Type: application/json; charset=utf-8');

// make input json
$inputJSON = file_get_contents('php://input');
$input = json_decode($inputJSON, TRUE);

// last output
$result_array = array();

// if not put device_id die
if($_SERVER['REQUEST_METHOD'] == 'POST' && array_key_exists('event_id', $input)){
    $event_id = $input['event_id'];

    // SELECT tbl_company.company_name FROM tbl_employee_company 
    // INNER JOIN tbl_employee ON tbl_employee.employee_id = tbl_employee_company.employee_id 
    // INNER JOIN tbl_company ON tbl_company.company_id = tbl_employee_company.company_id 
    // WHERE tbl_employee.employee_id = '01206';
    
    $sql = "SELECT tbl_event_log.id, tbl_event_log.employee_id, tbl_employee.first_name, tbl_employee.last_name, tbl_employee.middle_name, tbl_event_log.event_id, tbl_event.event_name, tbl_event_log.time_stamp 
    FROM tbl_event_log INNER JOIN tbl_employee ON tbl_employee.employee_id = tbl_event_log.employee_id INNER JOIN tbl_event ON tbl_event.event_id = tbl_event_log.event_id
    WHERE tbl_event_log.event_id = :event_id ORDER BY tbl_event_log.time_stamp DESC;";

    try {
        $get_sql= $conn->prepare($sql);
        $get_sql->bindParam(':event_id', $event_id, PDO::PARAM_STR);
        $get_sql->execute();
        $result_get_sql = $get_sql->fetchAll(PDO::FETCH_ASSOC);
        // echo json_encode($result_get_sql);
        foreach ($result_get_sql as $result) {
            $id = $result['employee_id'];
            // get company
            $get_company= $conn->prepare("SELECT tbl_company.company_name FROM tbl_employee_company 
            INNER JOIN tbl_employee ON tbl_employee.employee_id = tbl_employee_company.employee_id 
            INNER JOIN tbl_company ON tbl_company.company_id = tbl_employee_company.company_id 
            WHERE tbl_employee.employee_id = :id;");
            $get_company->bindParam(':id', $id, PDO::PARAM_STR);
            $get_company->execute();
            $result_get_company = $get_company->fetchAll(PDO::FETCH_ASSOC);
            $my_array = array('id'=>$result['id'],'employee_id'=>$result['employee_id'],'first_name'=>$result['first_name'] ?? 'NA','last_name'=>$result['last_name'] ?? 'NA','middle_name'=>$result['middle_name'] ?? 'NA','time_stamp'=>$result['time_stamp'],'company'=>$result_get_company,'event_id'=>$result['event_id'],'event_name'=>$result['event_name']);
            array_push($result_array,$my_array);
        }
        echo json_encode($result_array);
    } catch (PDOException $e) {
        echo json_encode(array('success'=>false,'message'=>$e->getMessage()));
    } finally{
        // Closing the connection.
        $conn = null;
    }
}else{
    echo json_encode(array('success'=>false,'message'=>'error input'));
    die();
}
?>