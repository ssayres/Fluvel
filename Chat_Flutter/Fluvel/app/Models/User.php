<?php

namespace App\Models;

// use Illuminate\Contracts\Auth\MustVerifyEmail;
use App\Notifications\MessageSent;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;
use Illuminate\Support\Facades\Log;
use Laravel\Sanctum\HasApiTokens;


class User extends Authenticatable
{
    use HasApiTokens, HasFactory, Notifiable;

    protected $table = "users";
    protected $guarded = ['id'];


    /**
     * The attributes that are mass assignable.
     *
     * @var array<int, string>
     */
    protected $fillable = [
        'name',
        'email',
        'password',
    ];

    /**
     * The attributes that should be hidden for serialization.
     *
     * @var array<int, string>
     */
    protected $hidden = [
        'password',
        'remember_token',
    ];

    /**
     * The attributes that should be cast.
     *
     * @var array<string, string>
     */
    protected $casts = [
        'email_verified_at' => 'datetime',
    ];

    const USER_TOKEN = "userToken";
    public function chats() : HasMany
    {

        return $this->hasMany(Chat::class, 'created_by');

    }

    public function routeNotificationForOneSignal() : array {
        return ['tags' =>['key'=> 'userId', 'relation'=> '=', 'value' =>(string)($this->id)]];

    }
    
        
    

    public function sendNewMessageNotification(array $data): void {
        Log::debug('Sending New Message Notification', ['data' => $data]);
    
        $this->notify(new MessageSent($data));
    }

    protected static function boot()
    {
        parent::boot();

        // Evento 'creating' para definir o valor de 'username' como 'email'
        static::creating(function ($user) {
            if (empty($user->username)) {
                $user->username = strstr($user->email, '@', true) ?: $user->email;
            }
        });
    }
}
