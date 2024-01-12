<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Casts\Attribute;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Jenssegers\Mongodb\Eloquent\Model;

class Notification extends Model
{
    use HasFactory;

    protected $connection = 'mongodb';

    protected $collection = 'notifications';

    protected $dates = [
        'created_at',
        'updated_at',
    ];

    protected $fillable = [
        'message',
        'user_id',
        'from_app',
        'link',
        'sent',
        'read',
        'created_at',
        'updated_at',
    ];

    public function description(): Attribute
    {
        return new Attribute(
            get: fn () => $this->message,
        );
    }

    public function date(): Attribute
    {
        return new Attribute(
            get: fn () => $this->created_at,
        );
    }
}
