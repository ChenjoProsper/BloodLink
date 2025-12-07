import 'package:intl/intl.dart';

class Formatters {
    static String formatCurrency(double amount) {
        final formatter = NumberFormat.currency(
        locale: 'fr_FR',
        symbol: 'FCFA',
        decimalDigits: 0,
        );
        return formatter.format(amount);
    }

    static String formatDate(DateTime date) {
        final formatter = DateFormat('dd/MM/yyyy', 'fr_FR');
        return formatter.format(date);
    }

    static String formatDateTime(DateTime dateTime) {
        final formatter = DateFormat('dd/MM/yyyy à HH:mm', 'fr_FR');
        return formatter.format(dateTime);
    }

    static String formatBloodGroup(String bloodGroup) {
        return bloodGroup.replaceAll('_', ' ');
    }

    static String timeAgo(DateTime dateTime) {
        final difference = DateTime.now().difference(dateTime);
        
        if (difference.inSeconds < 60) {
        return 'À l\'instant';
        } else if (difference.inMinutes < 60) {
        return 'Il y a ${difference.inMinutes} min';
        } else if (difference.inHours < 24) {
        return 'Il y a ${difference.inHours}h';
        } else if (difference.inDays < 7) {
        return 'Il y a ${difference.inDays}j';
        } else {
        return formatDate(dateTime);
        }
    }
}