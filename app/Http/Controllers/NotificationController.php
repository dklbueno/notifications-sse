<?php

namespace App\Http\Controllers;

use Carbon\Carbon;
use App\Models\Notification;
use Illuminate\Http\Request;

class NotificationController extends Controller
{
    public function stream()
    {
        return response()->stream(function () {  
            if (auth()->check()) {
                while (true) {
                    // echo "event: notifications\n";
                    // // $curDate = Carbon::now();
                    // echo 'data: {"user": "' . auth()->user()->id . '"}';                             
                    echo "\n\n";
                    $latestNotifications = Notification::where('sent', false)->latest()->first();
                    if ($latestNotifications && $latestNotifications->user_id == auth()->user()->id) {                                         
                        echo 'data: {"latest_user":"' . $latestNotifications->user_id . '", "latest_message":"' . $latestNotifications->message . '", "latest_from_app":"' . $latestNotifications->from_app . '"}' . "\n\n";
                        $latestNotifications->sent = true;
                        $latestNotifications->save();
                    }                
    
                    ob_flush();
                    flush();
    
                    // Break the loop if the client aborted the connection (closed the page)
                    if (connection_aborted()) {break;}
                    // usleep(50000); // 50ms
                    sleep(2);
                }
                
            }          
            
        }, 200, [
            'Cache-Control' => 'no-cache',
            'Content-Type' => 'text/event-stream',
        ]);
    }

    public function store(Request $request)
    {
        Notification::create([
            'user_id' => $request->user_id,
            'from_app' => $request->from_app,
            'message' => $request->message,
            'sent' => false,
            'read' => false,
            'created_at' => Carbon::now()->toDateTimeString(),
        ]);
    }
}
