<?php

namespace App\Http\Controllers;

use App\Events\NewMessageSent;
use App\Http\Requests\GetMessageRequest;
use App\Http\Requests\StoreMessageRequest;
use App\Models\Chat;
use App\Models\ChatMessage;
use App\Models\User;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class ChatMessageController extends Controller
{
    
    /**
     * 
     * 
     * @param GetMessageRequest $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function index(GetMessageRequest $request) : JsonResponse{
        $data = $request->validated();
        $chatId = $data['chat_id'];
        $currentPage = $data['page'];
        $pageSize = $data['page_size'] ?? 15;

        $messages = ChatMessage::where('chat_id', $chatId)
        ->with('user')
        ->latest('created_at')
        ->simplePaginate(
            $pageSize,
            ['*'],
            'page',
            $currentPage
        );

        return $this->success($messages->getCollection());
    }

    /**
     * create a new chat message
     * 
     * @param $StoreMessageRequest $request
     * @return JsonResponse
     * 
     */
    public function store(StoreMessageRequest $request){

        $data = $request->validated();
        $data['user_id'] = auth()->user()->id;

        $chatMessage = ChatMessage::create($data);
        $chatMessage->load('user');

        /// TODO send broadcast event to pusher and send notification to onesignal services

        $this->sendNotificationToOther($chatMessage);
        return $this->success($chatMessage, 'Message sent successfully');

    }

    /**
     * Send notification to other users
     * 
     * @param ChatMessage $chatMessage
     * 
     */
    private function sendNotificationToOther(ChatMessage $chatMessage): void {
        //$chatId = $chatMessage->chat_id;
        
        broadcast(new NewMessageSent($chatMessage))->toOthers();
    
        $user = auth()->user();
        $userId = $user->id;
    
        $chat = Chat::where('id', $chatMessage->chat_id)
            ->with(['participants' => function ($query) use ($userId) {
                $query->where('user_id', '!=', $userId); // Adicionando ponto e vírgula aqui
            }])
            ->first();
            if(count($chat->participants) > 0){
                $otherUserId = $chat->participants[0]->user_id;

                $otherUser = User::where('id', $otherUserId)->first();
                $otherUser->sendNewMessageNotification([
                    'messageData'=>[
                        'sendName' =>$user->name,
                        'message' =>$chatMessage->message,
                        'chatId' =>$chatMessage->chat_id
                    ]
                ]);

            }
    }

}
