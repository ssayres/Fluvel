<?php

namespace App\Http\Controllers;

use App\Http\Requests\GetchChatRequest;
use App\Http\Requests\StoreChatRequest;
use App\Models\Chat;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class ChatController extends Controller
{
    /**
     * Display a listing of the resource.
     *
     * @param GetchChatRequest $request
     * @return JsonResponse
     */
    public function index(GetchChatRequest $request)
    {
        $data = $request->validated();

        $isPrivate = 1;
        if($request->has('is_private')){
            $isPrivate = (int)$data['is_private'];
        }

        $chats = Chat::where('is_private', $isPrivate)
        ->hasParticipant(auth()->user()->id)
        ->whereHas('messages')
        ->with('lastMessage.user', 'participants.user')
        ->latest('updated_at')
        ->get();
        return $this->success($chats);

    }

    /**
     * Store a newly created resource in storage.
     *
     * @param  StoreChatRequest $request
     * @return JsonResponse
     */
    public function store(StoreChatRequest $request) : JsonResponse
    {
        $data = $this->preparedStoreData($request);
        if($data['userId'] == $data['otherUserId']){
            return $this->error('Você não pode criar um chat sozinho');
        }

        $previousChat = $this->getPreviousChat($data['otherUserId']);

        if($previousChat == null ){

            $chat = Chat::create($data['data']);
            $chat->participants()->createMany([
                [
                    'user_id' =>$data['userId'],
                ],
                [
                    'user_id' =>$data['otherUserId'],
                ]
                ]);

                $chat->refresh()->load('lastMessage.user', 'participants.user');
                return $this->success($chat);
        }
        return $this->success($previousChat->load('lastMessage.user', 'participants.user'));

    }

    /**
     * 
     * @param int $otherUserId
     * @return mixed
     */
    private function getPreviousChat(int $otherUserId) : mixed{

        $userId = auth()->user()->id;

        

        return Chat::where('is_private',1)
        ->whereHas('participants', function ($query) use ($userId){
            $query->where('user_id',$userId);
        })
        ->whereHas('participants', function ($query) use ($otherUserId){
            $query->where('user_id', $otherUserId);
        })
        ->first();
    }
    /**
     * 
     * @param StoreChatRequest $request
     * @return array
     */
    private function preparedStoreData(StoreChatRequest $request){
        $data = $request->validated();
        $otherUserId = (int)$data['user_id'];
        unset($data['user_id']);
        $data['created_by'] = auth()->user()->id;

        return [
            'otherUserId'=>$otherUserId,
            'userId' =>auth()->user()->id,
            'data' => $data
        ];
    }
    /**
     * Display the specified resource.
     *
     * @param  int  $id
     * @return \Illuminate\Http\Response
     */
    
   
     /**
     * Display a listing of the resource.
     *
     * @param Chat $chat
     * @return JsonResponse
     */
      
     public function show(Chat $chat)
    {
        $chat->load('lastMessage.user', 'participants.user');
        return $this->success($chat);
    }

    /**
     * Update the specified resource in storage.
     *
     * @param  \Illuminate\Http\Request  $request
     * @param  int  $id
     * @return \Illuminate\Http\Response
     */
    public function update(Request $request, $id)
    {
        //
    }

    /**
     * Remove the specified resource from storage.
     *
     * @param  int  $id
     * @return \Illuminate\Http\Response
     */
    public function destroy($id)
    {
        //
    }
}
